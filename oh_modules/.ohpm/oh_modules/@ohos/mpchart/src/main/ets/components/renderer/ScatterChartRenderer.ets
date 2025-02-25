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
import ChartAnimator from '../animation/ChartAnimator';
import ChartPixelMap from '../data/ChartPixelMap';
import { ScatterData } from '../data/ScatterData';
import IValueFormatter from '../formatter/IValueFormatter';
import Highlight from '../highlight/Highlight';
import { ScatterDataProvider } from '../interfaces/dataprovider/ScatterDataProvider';
import IScatterDataSet from '../interfaces/datasets/IScatterDataSet';
import { JArrayList } from '../utils/JArrayList';
import { LogUtil } from '../utils/LogUtil';
import MPPointD from '../utils/MPPointD';
import MPPointF from '../utils/MPPointF';
import Transformer from '../utils/Transformer';
import Utils from '../utils/Utils';
import ViewPortHandler from '../utils/ViewPortHandler';
import LineScatterCandleRadarRenderer from './LineScatterCandleRadarRenderer';
import IShapeRenderer from './scatter/IShapeRenderer';

export default class ScatterChartRenderer extends LineScatterCandleRadarRenderer {
  public mChart: ScatterDataProvider;

  public constructor(chart: ScatterDataProvider, animator: ChartAnimator, viewPortHandler: ViewPortHandler) {
    super(animator, viewPortHandler);
    this.mChart = chart;
  }

  public initBuffers() {
  }

  public drawData(c: CanvasRenderingContext2D) {

    let scatterData: ScatterData | null = this.mChart.getScatterData();
    if (!scatterData) {
      return;
    }

    for (let index = 0; index < scatterData.getDataSets().size(); index++) {
      const set = scatterData.getDataSets().get(index);
      if (set.isVisible()) {
        this.drawDataSet(c, set);
      }
    }

  }

  private mPixelBuffer: number[] = new Array<number>(2)

  protected drawDataSet(c: CanvasRenderingContext2D, dataSet: IScatterDataSet) {

    if (dataSet.getEntryCount() < 1) return;
    if (this.mViewPortHandler && this.mAnimator) {

      let viewPortHandler: ViewPortHandler = this.mViewPortHandler;

      let trans: Transformer | null = this.mChart.getTransformer(dataSet.getAxisDependency());

      const phaseY = this.mAnimator.getPhaseY();

      let renderer: IShapeRenderer = dataSet.getShapeRenderer();
      if (renderer == null) {
        LogUtil.log("MISSING", "There's no IShapeRenderer specified for ScatterDataSet");
        return;
      }

      const max = (Math.min(
        Math.ceil(dataSet.getEntryCount() * this.mAnimator.getPhaseX()),
        dataSet.getEntryCount()));

      for (let i = 0; i < max; i++) {

        let e = dataSet.getEntryForIndex(i);

        this.mPixelBuffer[0] = e.getX();
        this.mPixelBuffer[1] = e.getY() * phaseY;

        if (!trans) continue;
        trans.pointValuesToPixel(this.mPixelBuffer);

        if (!viewPortHandler.isInBoundsRight(this.mPixelBuffer[0])) break;

        if (!viewPortHandler.isInBoundsLeft(this.mPixelBuffer[0]) || !viewPortHandler.isInBoundsY(this.mPixelBuffer[1])) continue;

        this.mRenderPaint.setColor(dataSet.getColor(i / 2));
        renderer.renderShape(
          c, dataSet, this.mViewPortHandler,
          this.mPixelBuffer[0], this.mPixelBuffer[1],
          this.mRenderPaint);
      }
    }
  }

  public drawValues(c: CanvasRenderingContext2D) {

    // if values are drawn
    if (this.isDrawingValuesAllowed(this.mChart)) {

      let data = this.mChart.getScatterData();
      if (!data) {
        return;
      }
      let dataSets: JArrayList<IScatterDataSet> = data.getDataSets();

      for (let i = 0; i < data.getDataSetCount(); i++) {

        let dataSet: IScatterDataSet = dataSets.get(i);

        if (!this.shouldDrawValues(dataSet) || dataSet.getEntryCount() < 1) continue;

        // apply the text-styling defined by the DataSet
        this.applyValueTextStyle(dataSet);

        if (!this.mChart || !this.mXBounds || !this.mAnimator) continue
        this.mXBounds.set(this.mChart, dataSet);

        let positions: number[] = this.mChart.getTransformer(dataSet.getAxisDependency())!
          .generateTransformedValuesScatter(dataSet,
            this.mAnimator.getPhaseX(), this.mAnimator.getPhaseY(), this.mXBounds.min, this.mXBounds.max);

        const shapeSize = Utils.handleDataValues(dataSet.getScatterShapeSize());

        let iconsOffset: MPPointF = MPPointF.getInstance(undefined, undefined, dataSet.getIconsOffset());
        iconsOffset.x = Utils.handleDataValues(iconsOffset.x);
        iconsOffset.y = Utils.handleDataValues(iconsOffset.y);

        if (!positions) continue
        for (let j = 0; j < positions.length; j += 2) {

          if (!this.mViewPortHandler || !this.mViewPortHandler.isInBoundsRight(positions[j])) break;

          // make sure the lines don't do shitty things outside bounds
          if ((!this.mViewPortHandler.isInBoundsLeft(positions[j]) || !this.mViewPortHandler.isInBoundsY(positions[j + 1]))) continue;

          const entry = dataSet.getEntryForIndex(j / 2 + this.mXBounds.min);

          if (dataSet && dataSet.isDrawValuesEnabled()) {
            // let valueFormatter: IValueFormatter | null = dataSet.getValueFormatter();
            // if (valueFormatter) {
            this.drawValue(
              c,
              dataSet.getValueFormatter() !,
              entry.getY(),
              entry,
              i,
              positions[j],
              positions[j + 1] - shapeSize,
              dataSet.getValueTextColor(j / 2 + this.mXBounds.min));
            // }
          }

          if (entry.getIcon() != null && dataSet.isDrawIconsEnabled()) {

            let icon: ChartPixelMap | null = entry.getIcon();
            if (!icon) continue
            Utils.drawImage(
              c,
              icon,
              Utils.parseInt(positions[j]+iconsOffset.x),
              Utils.parseInt(positions[j + 1]+iconsOffset.y),
              icon.getWidth(),
              icon.getHeight());
          }
        }

        MPPointF.recycleInstance(iconsOffset);
      }
    }
  }

  public drawExtras(c: CanvasRenderingContext2D) {

  }

  public drawHighlighted(c: CanvasRenderingContext2D, indices: Highlight[]) {

    let scatterData: ScatterData | null = this.mChart.getScatterData();
    if (!scatterData) {
      return;
    }

    for (let i = 0;i < indices.length; i++) {
      let high = indices[i];
      let set: IScatterDataSet | null = scatterData.getDataSetByIndex(high.getDataSetIndex());

      if (set == null || !set.isHighlightEnabled())
        continue;

      const e = set.getEntryForXValue(high.getX(), high.getY());

      if (!e || !this.isInBoundsX(e, set) || !this.mAnimator) continue;

      let pix: MPPointD = this.mChart.getTransformer(set.getAxisDependency())!
        .getPixelForValues(e.getX(), e.getY() * this.mAnimator
          .getPhaseY());

      high.setDraw(pix.x, pix.y);

      // draw the lines
      this.drawHighlightLines(c, pix.x, pix.y, set);
    }
  }
}