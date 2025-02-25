/*
 * Copyright (C) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Highlight from '../highlight/Highlight';
import MPPointF from '../utils/MPPointF';
import { JArrayList } from '../utils/JArrayList';
import BubbleEntry from '../data/BubbleEntry';
import Transformer from '../utils/Transformer';
import BubbleData from '../data/BubbleData';
import BarLineScatterCandleBubbleRenderer from './BarLineScatterCandleBubbleRenderer'
import Paint, { Style } from '../data/Paint'
import Utils from '../utils/Utils'
import IBubbleDataSet from '../interfaces/datasets/IBubbleDataSet'
import BubbleDataProvider from '../interfaces/dataprovider/BubbleDataProvider';
import ChartAnimator from '../animation/ChartAnimator';
import ViewPortHandler from '../utils/ViewPortHandler';
import ChartPixelMap from '../data/ChartPixelMap';
import { ColorTemplate, ChartColor } from '../utils/ColorTemplate'
import HashMap from '@ohos.util.HashMap';

export default class BubbleChartRenderer extends BarLineScatterCandleBubbleRenderer {
  public mChart: BubbleDataProvider;
  textSizeCache = new HashMap<string, TextMetrics>();

  constructor(chart: BubbleDataProvider, animator: ChartAnimator, viewPortHandler: ViewPortHandler) {
    super(animator, viewPortHandler);
    this.mChart = chart;

    this.mRenderPaint.setStyle(Style.FILL);

    this.mHighlightPaint.setStyle(Style.STROKE);
    this.mHighlightPaint.setStrokeWidth(Utils.handleDataValues(1.5));
  }

  // @Override
  public initBuffers(): void {

  }

  // @Override
  public drawData(c: CanvasRenderingContext2D): void {

    let bubbleData: BubbleData | null = this.mChart.getBubbleData();

    if (!bubbleData) {
      return;
    }
    for (let i = 0;i < bubbleData.getDataSets().size(); i++) {
      if (bubbleData.getDataSets().get(i).isVisible()) {
        this.drawDataSet(c, bubbleData.getDataSets().get(i));
      }
    }
  }

  private sizeBuffer: number[] = new Array<number>(4);
  private pointBuffer: number[] = new Array<number>(2);

  protected getShapeSize(entrySize: number, maxSize: number, reference: number, normalizeSize: boolean): number {
    let factor: number = normalizeSize ? ((maxSize == 0) ? 1 : /*(float)*/ Math.sqrt(entrySize / maxSize)) : entrySize;
    let shapeSize: number = reference * factor;
    return shapeSize;
  }

  protected drawDataSet(c: CanvasRenderingContext2D, dataSet: IBubbleDataSet): void {

    if (!dataSet || dataSet.getEntryCount() < 1) return;


    let trans: Transformer | null = this.mChart.getTransformer(dataSet.getAxisDependency());
    if (this.mAnimator && this.mViewPortHandler) {

      let phaseY: number = this.mAnimator.getPhaseY();

      this.mXBounds?.set(this.mChart, dataSet);

      this.sizeBuffer[0] = 0;
      this.sizeBuffer[2] = 1;

      trans?.pointValuesToPixel(this.sizeBuffer);

      let normalizeSize: boolean = dataSet.isNormalizeSizeEnabled();

      // calculate the full width of 1 step on the x-axis
      let maxBubbleWidth: number = Math.abs(this.sizeBuffer[2] - this.sizeBuffer[0]);
      let maxBubbleHeight: number = Math.abs(this.mViewPortHandler.contentBottom() - this.mViewPortHandler.contentTop());
      let referenceSize: number = Math.min(maxBubbleHeight, maxBubbleWidth);
      if (!this.mXBounds) return
      for (let j: number = this.mXBounds.min; j <= this.mXBounds.range + this.mXBounds.min; j++) {

        let entry: BubbleEntry = dataSet.getEntryForIndex(j);

        this.pointBuffer[0] = entry.getX();
        this.pointBuffer[1] = (entry.getY()) * phaseY;
        trans?.pointValuesToPixel(this.pointBuffer);

        let shapeHalf: number = this.getShapeSize(entry.getSize(), dataSet.getMaxSize(), referenceSize, normalizeSize) / 2;

        if (!this.mViewPortHandler.isInBoundsTop(this.pointBuffer[1] + shapeHalf) || !this.mViewPortHandler.isInBoundsBottom(this.pointBuffer[1] - shapeHalf)) continue;

        if (!this.mViewPortHandler.isInBoundsLeft(this.pointBuffer[0] + shapeHalf)) continue;


        if (!this.mViewPortHandler.isInBoundsRight(this.pointBuffer[0] - shapeHalf)) break;
        let color: number = dataSet.getColor(j);
        this.mRenderPaint.setColor(color)

        Utils.resetContext2DWithoutFont(c, this.mRenderPaint);

        c.beginPath();
        c.arc(this.pointBuffer[0], this.pointBuffer[1], shapeHalf, 0, 2 * Math.PI, true);
        c.stroke();
        c.fill();
        c.closePath();

      }
    }
  }

  // @Override
  public drawValues(c: CanvasRenderingContext2D): void {

    let bubbleData: BubbleData | null = this.mChart.getBubbleData();

    if (bubbleData == null)
      return;

    // if values are drawn
    if (this.isDrawingValuesAllowed(this.mChart) && this.mXBounds) {

      let dataSets: JArrayList<IBubbleDataSet> = bubbleData.getDataSets();

      let lineHeight: number = Utils.getLabelTextSize(this.mValuePaint, "1", this.textSizeCache).height;

      for (let i: number = 0; i < dataSets.size(); i++) {

        let dataSet: IBubbleDataSet = dataSets.get(i);

        if (!this.shouldDrawValues(dataSet) || dataSet.getEntryCount() < 1) continue;

        // apply the text-styling defined by the DataSet
        this.applyValueTextStyle(dataSet);
        if (!this.mAnimator || !this.mViewPortHandler) continue
        let phaseX: number = Math.max(0.0, Math.min(1.0, this.mAnimator.getPhaseX()));
        let phaseY: number = this.mAnimator.getPhaseY();

        this.mXBounds.set(this.mChart, dataSet);
        let positions: number[] = this.mChart.getTransformer(dataSet.getAxisDependency())!
          .generateTransformedValuesBubble(dataSet, phaseY, this.mXBounds.min, this.mXBounds.max);

        let alpha: number = phaseX == 1 ? phaseY : phaseX;

        let iconsOffset: MPPointF = MPPointF.getInstance(undefined, undefined, dataSet.getIconsOffset());
        iconsOffset.x = Utils.handleDataValues(iconsOffset.x);
        iconsOffset.y = Utils.handleDataValues(iconsOffset.y);

        for (let j: number = 0; j < positions.length; j += 2) {

          let valueTextColor: number = dataSet.getValueTextColor(j / 2 + this.mXBounds.min);
          valueTextColor = ChartColor.argb(Math.round(255.0 * alpha), ChartColor.red(valueTextColor),
            ChartColor.green(valueTextColor), ChartColor.blue(valueTextColor));

          let x: number = positions[j];
          let y: number = positions[j + 1];

          if ((!this.mViewPortHandler.isInBoundsLeft(x) || !this.mViewPortHandler.isInBoundsY(y))) continue;

          let entry: BubbleEntry = dataSet.getEntryForIndex(j / 2 + this.mXBounds.min);

          if (dataSet && dataSet.isDrawValuesEnabled()) {

            this.drawValue(c, dataSet.getValueFormatter()!, entry.getSize(), entry, i, x, y + (0.5 * lineHeight), valueTextColor);
          }

          if (entry.getIcon() != null && dataSet.isDrawIconsEnabled()) {

            let icon: ChartPixelMap | null = entry.getIcon();
            if (icon) {
              Utils.drawImage(
                c,
                icon,
                x + iconsOffset.x,
                y + iconsOffset.y,
                icon.getWidth(),
                icon.getHeight())
            }
          }
        }

        MPPointF.recycleInstance(iconsOffset);
      }
    }
  }

  // @Override
  public drawExtras(c: CanvasRenderingContext2D): void {
  }

  private _hsvBuffer: number[] = new Array<number>(3);

  // @Override
  public drawHighlighted(c: CanvasRenderingContext2D, indices: Highlight[]): void {

    let bubbleData: BubbleData | null = this.mChart.getBubbleData();
    if (!bubbleData) {
      return;
    }
    if (this.mAnimator && this.mViewPortHandler) {
      let phaseY: number = this.mAnimator.getPhaseY();

      for (let i = 0; i < indices.length; i++) {

        let set: IBubbleDataSet | null = bubbleData.getDataSetByIndex(indices[i].getDataSetIndex());

        if (set == null || !set.isHighlightEnabled()) continue;

        let entry: BubbleEntry | null = set.getEntryForXValue(indices[i].getX(), indices[i].getY());

        if (!entry || entry.getY() != indices[i].getY()) continue;

        if (!this.isInBoundsX(entry, set)) continue;

        let trans: Transformer | null = this.mChart.getTransformer(set.getAxisDependency());

        this.sizeBuffer[0] = 0;
        this.sizeBuffer[2] = 1;

        trans?.pointValuesToPixel(this.sizeBuffer);

        let normalizeSize: boolean = set.isNormalizeSizeEnabled();

        // calculate the full width of 1 step on the x-axis
        let maxBubbleWidth: number = Math.abs(this.sizeBuffer[2] - this.sizeBuffer[0]);
        let maxBubbleHeight: number = Math.abs(
          this.mViewPortHandler.contentBottom() - this.mViewPortHandler.contentTop());
        let referenceSize: number = Math.min(maxBubbleHeight, maxBubbleWidth);

        this.pointBuffer[0] = entry.getX();
        this.pointBuffer[1] = (entry.getY()) * phaseY;
        trans?.pointValuesToPixel(this.pointBuffer);

        indices[i].setDraw(this.pointBuffer[0], this.pointBuffer[1]);

        let shapeHalf: number = this.getShapeSize(entry.getSize(),
          set.getMaxSize(),
          referenceSize,
          normalizeSize) / 2;

        if (!this.mViewPortHandler.isInBoundsTop(this.pointBuffer[1] + shapeHalf) || !this.mViewPortHandler.isInBoundsBottom(this.pointBuffer[1] - shapeHalf)) continue;

        if (!this.mViewPortHandler.isInBoundsLeft(this.pointBuffer[0] + shapeHalf)) continue;

        if (!this.mViewPortHandler.isInBoundsRight(this.pointBuffer[0] - shapeHalf)) break;

        let originalColor: number = set.getColor(/*(int)*/ entry.getX());

        ChartColor.RGBToHSV(ChartColor.red(originalColor), ChartColor.green(originalColor), ChartColor.blue(originalColor), this._hsvBuffer);
        this._hsvBuffer[2] *= 0.5;
        let color: number = ChartColor.HSVToColor(ChartColor.alpha(originalColor), this._hsvBuffer);

        this.mHighlightPaint.setColor(color);
        this.mHighlightPaint.setStrokeWidth(set.getHighlightCircleWidth());
        Utils.resetContext2DWithoutFont(c, this.mHighlightPaint);
        c.beginPath();
        c.arc(this.pointBuffer[0], this.pointBuffer[1], shapeHalf, 0, 2 * Math.PI);
        c.stroke();
        c.closePath();
      }
    }
  }
}
