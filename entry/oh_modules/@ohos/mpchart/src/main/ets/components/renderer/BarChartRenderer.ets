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
import BarBuffer from '../buffer/BarBuffer';
import BarData from '../data/BarData';
import BarEntry from '../data/BarEntry';
import ChartPixelMap from '../data/ChartPixelMap';
import Paint, { Style } from '../data/Paint';
import MyRect from '../data/Rect';
import IValueFormatter from '../formatter/IValueFormatter';
import Highlight from '../highlight/Highlight';
import Range from '../highlight/Range';
import BarDataProvider from '../interfaces/dataprovider/BarDataProvider';
import IBarDataSet from '../interfaces/datasets/IBarDataSet';
import Fill, { FillDirection } from '../utils/Fill';
import { JArrayList } from '../utils/JArrayList';
import MPPointF from '../utils/MPPointF';
import Transformer from '../utils/Transformer';
import Utils, { RoundCornerType } from '../utils/Utils';
import ViewPortHandler from '../utils/ViewPortHandler';
import BarLineScatterCandleBubbleRenderer from './BarLineScatterCandleBubbleRenderer';
import HashMap from '@ohos.util.HashMap';

export default class BarChartRenderer extends BarLineScatterCandleBubbleRenderer {
  public mChart: BarDataProvider | null = null;
  /**
   * the rect object that is used for drawing the bars
   */
  protected mBarRect: MyRect = new MyRect();
  protected mBarBuffers: BarBuffer[] = new Array<BarBuffer>();
  protected mShadowPaint: Paint | null = null;
  protected mBarBorderPaint: Paint | null = null;
  textSizeCache = new HashMap<string, TextMetrics>();

  // private maxTextOffset: number = 0;

  // private width:number = 0;
  // private height:number = 0;
  // private singleWidth:number = 0;
  // private marginCount:number  = 12;
  // private marginRight:number  = 0;
  // private count :number = 0;

  constructor(chart: BarDataProvider, animator: ChartAnimator, viewPortHandler: ViewPortHandler) {
    super(animator, viewPortHandler);
    this.mChart = chart;

    this.mHighlightPaint = new Paint();
    this.mHighlightPaint.setStyle(Style.FILL);
    this.mHighlightPaint.setColor(Color.Black);
    // set alpha after color
    this.mHighlightPaint.setGlobalAlpha(120 / 255);

    this.mShadowPaint = new Paint();
    this.mShadowPaint.setStyle(Style.FILL);

    this.mBarBorderPaint = new Paint();
    this.mBarBorderPaint.setStyle(Style.STROKE);
  }

  public initBuffers(): void {
    if (!this.mChart) {
      return;
    }
    let barData: BarData | null = this.mChart.getBarData();
    if (barData) {
      this.mBarBuffers = new Array(barData.getDataSetCount());
      for (let i = 0; i < this.mBarBuffers.length; i++) {
        let dataSet: IBarDataSet | null = barData.getDataSetByIndex(i);
        if (dataSet) {
          this.mBarBuffers[i] = new BarBuffer(dataSet.getEntryCount() * 4 * (dataSet.isStacked() ? dataSet.getStackSize() : 1),
            barData.getDataSetCount(), dataSet.isStacked());
        }
      }
    }
  }

  // @Override
  public drawData(c: CanvasRenderingContext2D): void {

    if (!this.mChart) {
      return
    }
    let barData: BarData | null = this.mChart.getBarData();
    if (barData) {
      for (let i = 0; i < barData.getDataSetCount(); i++) {
        let set: IBarDataSet | null = barData.getDataSetByIndex(i);

        if (set && set.isVisible()) {
          this.drawDataSet(c, set, i);
        }
      }
    }
  }

  protected mBarShadowRectBuffer: MyRect = new MyRect();

  protected drawDataSet(c: CanvasRenderingContext2D, dataSet: IBarDataSet, index: number): void {

    if (!this.mChart) {
      return;
    }
    let trans: Transformer | null = this.mChart.getTransformer(dataSet.getAxisDependency());

    if (this.mBarBorderPaint) {
      this.mBarBorderPaint.setColor(dataSet.getBarBorderColor());
      this.mBarBorderPaint.setStrokeWidth(Utils.handleDataValues(dataSet.getBarBorderWidth()));

    }

    const drawBorder: boolean = dataSet.getBarBorderWidth() > 0.0;

    let phaseX: number = 1;
    let phaseY: number = 1;
    if (this.mAnimator) {
      phaseX = this.mAnimator.getPhaseX();
      phaseY = this.mAnimator.getPhaseY();
    }

    // draw the bar shadow before the values
    if (this.mShadowPaint && this.mChart.isDrawBarShadowEnabled()) {
      this.mShadowPaint.setColor(dataSet.getBarShadowColor());

      let barData: BarData | null = this.mChart.getBarData();
      if (!barData) {
        return;
      }
      const radius = barData? barData.getTopRadius(): 0;
      const barWidth: number = barData.getBarWidth();
      const barWidthHalf: number = barWidth / 2.0;
      let x: number = 0;

      for (let i = 0,
        count = Math.min(Number(Math.ceil(Number(dataSet.getEntryCount()) * phaseX)), dataSet.getEntryCount()); i < count; i++) {

        let e: BarEntry = dataSet.getEntryForIndex(i);

        x = e.getX();

        this.mBarShadowRectBuffer.left = x - barWidthHalf;
        this.mBarShadowRectBuffer.right = x + barWidthHalf;

        if (trans) {
          trans.rectValueToPixel(this.mBarShadowRectBuffer);
        }

        if (!this.mViewPortHandler || !this.mViewPortHandler.isInBoundsLeft(this.mBarShadowRectBuffer.right)) {
          continue;
        }

        if (!this.mViewPortHandler || !this.mViewPortHandler.isInBoundsRight(this.mBarShadowRectBuffer.left)) {
          break;
        }

        this.mBarShadowRectBuffer.top = this.mViewPortHandler ? this.mViewPortHandler.contentTop() : 0;
        this.mBarShadowRectBuffer.bottom = this.mViewPortHandler ? this.mViewPortHandler.contentBottom() : 0;
        if (this.mShadowPaint) {
          switch (this.mShadowPaint.getStyle()) {
            case Style.STROKE:
              Utils.drawStrokeRect(radius > 0, c, this.mShadowPaint, this.mBarShadowRectBuffer.left, this.mBarShadowRectBuffer.top, this.mBarShadowRectBuffer.right, this.mBarShadowRectBuffer.bottom, radius, 'both'); // 阴影上下圆角都绘制比较好
              break;
            case Style.FILL:
            case Style.FILL_AND_STROKE:
            default:
              Utils.drawFillRect(radius > 0, c, this.mShadowPaint, this.mBarShadowRectBuffer.left, this.mBarShadowRectBuffer.top, this.mBarShadowRectBuffer.right, this.mBarShadowRectBuffer.bottom, radius, 'both'); // 阴影上下圆角都绘制比较好
              break;
          }
        }
      }
    }

    // initialize the buffer
    let buffer: BarBuffer = this.mBarBuffers[index];
    buffer.setPhases(phaseX, phaseY);
    buffer.setDataSet(index);
    buffer.setInverted(this.mChart.isInverted(dataSet.getAxisDependency()));
    let barData: BarData | null = this.mChart.getBarData();
    if (barData) {
      buffer.setBarWidth(barData.getBarWidth());
    }

    buffer.feed(dataSet);
    if (trans) {
      trans.pointValuesToPixel(buffer.buffer);
    }

    let fills: JArrayList<Fill> | null = dataSet.getFills();
    const isCustomFill: boolean = !!fills && !fills.isEmpty();
    const isSingleColor: boolean = dataSet.getColors().size() == 1;
    const isInverted: boolean = this.mChart.isInverted(dataSet.getAxisDependency());

    if (isSingleColor) {
      this.mRenderPaint.setColor(dataSet.getColor());
    }

    for (let j = 0, pos = 0; j < buffer.size(); j += 4, pos++) {

      if (!this.mViewPortHandler || !this.mViewPortHandler.isInBoundsLeft(buffer.buffer[j + 2]))
        continue;
      if (!this.mViewPortHandler || !this.mViewPortHandler.isInBoundsRight(buffer.buffer[j]))
        break;
      if (!isSingleColor) {
        // Set the color for the currently drawn value. If the index
        // is out of bounds, reuse colors.
        this.mRenderPaint.setColor(dataSet.getColor(pos));
      }

      const radius = barData ? barData.getTopRadius() : 0;

      //顶部的矩形才需要绘制圆角
      let isDrawRounded = radius != 0 && (j + 4 >= buffer.size() || (j + 4 < buffer.size() && buffer.buffer[j] != buffer.buffer[j + 4]));

      // 圆角位置：同时受 值 和 图表是否 inverted 影响
      let cornerType: RoundCornerType = 'up'
      if(dataSet.getEntryForIndex(pos) != null){
        if (isInverted) {
          cornerType = dataSet.getEntryForIndex(pos).getY() > 0 ? 'down' : 'up'
        } else {
          cornerType = dataSet.getEntryForIndex(pos).getY() > 0 ? 'up' : 'down'
        }
      }

      if (isCustomFill) {

        let fill: Fill | null = dataSet.getFill(pos);
        if (fill) {
          fill.fillRect(
            c, this.mRenderPaint,
            buffer.buffer[j],
            buffer.buffer[j + 1],
            buffer.buffer[j + 2],
            buffer.buffer[j + 3],
            isInverted ? FillDirection.DOWN : FillDirection.UP, radius, cornerType);
        }

      } else {
        Utils.drawFillRect(isDrawRounded, c, this.mRenderPaint, buffer.buffer[j], buffer.buffer[j + 1], buffer.buffer[j + 2], buffer.buffer[j + 3], radius, cornerType);
      }

      if (drawBorder) {
        if(this.mBarBorderPaint != null){
          Utils.drawStrokeRect(isDrawRounded, c, this.mBarBorderPaint, buffer.buffer[j], buffer.buffer[j + 1], buffer.buffer[j + 2], buffer.buffer[j + 3], radius, cornerType);
        }
      }
    }
  }


  protected prepareBarHighlight(x: number, y1: number, y2: number, barWidthHalf: number, trans: Transformer): void {

    let left: number = x - barWidthHalf;
    let right: number = x + barWidthHalf;
    let top: number = y1;
    let bottom: number = y2;

    this.mBarRect.set(left, top, right, bottom);
    if (trans) {
      trans.rectToPixelPhase(this.mBarRect, (this.mAnimator ? this.mAnimator.getPhaseY() : 1));
    }
  }

  // @Override
  public drawValues(c: CanvasRenderingContext2D): void {
    if (!this.mChart || !this.mChart.getBarData()) {
      return;
    }
    // if values are drawn
    if (this.isDrawingValuesAllowed(this.mChart)) {
      let barData: BarData | null = this.mChart.getBarData();
      if (!barData) {
        return;
      }
      let dataSets: JArrayList<IBarDataSet> = barData.getDataSets();

      const valueOffsetPlus: number = 0;
      let posOffset: number = 0;
      let negOffset: number = 0;
      let drawValueAboveBar: boolean = this.mChart.isDrawValueAboveBarEnabled();
      for (let i = 0; i < barData.getDataSetCount(); i++) {

        let dataSet: IBarDataSet = dataSets.get(i);

        if (!this.shouldDrawValues(dataSet))
          continue;

        // apply the text-styling defined by the DataSet
        this.applyValueTextStyle(dataSet);

        let isInverted: boolean = this.mChart.isInverted(dataSet.getAxisDependency());

        // calculate the correct offset depending on the draw position of
        // the value
        let valueTextHeight: number = Utils.getLabelTextSize(this.mValuePaint, "8", this.textSizeCache).height;
        posOffset = (drawValueAboveBar ? -valueOffsetPlus : valueTextHeight + valueOffsetPlus);
        negOffset = (drawValueAboveBar ? valueTextHeight + valueOffsetPlus : -valueOffsetPlus);

        if (isInverted) {
          posOffset = -posOffset - valueTextHeight;
          negOffset = -negOffset - valueTextHeight;
        }

        // get the buffer
        let buffer: BarBuffer = this.mBarBuffers[i];

        const phaseY: number = this.mAnimator ? this.mAnimator.getPhaseY() : 1;

        let iconsOffset: MPPointF = MPPointF.getInstance(0, 0, dataSet.getIconsOffset());
        iconsOffset.x = Utils.handleDataValues(iconsOffset.x);
        iconsOffset.y = Utils.handleDataValues(iconsOffset.y);

        // if only single values are drawn (sum)
        if (!dataSet.isStacked()) {

          for (let j = 0; j < buffer.buffer.length * (this.mAnimator ? this.mAnimator.getPhaseX() : 1); j += 4) {

            let x: number = (buffer.buffer[j] + buffer.buffer[j + 2]) / 2;

            if (!this.mViewPortHandler || !this.mViewPortHandler.isInBoundsRight(x))
              break;

            if (!this.mViewPortHandler || !this.mViewPortHandler.isInBoundsY(buffer.buffer[j + 1])
            || !this.mViewPortHandler.isInBoundsLeft(x))
              continue;

            let entry: BarEntry = dataSet.getEntryForIndex(j / 4);
            let val: number = entry.getY();

            if (dataSet.isDrawValuesEnabled()) {
              let valueFormatter: IValueFormatter | null = dataSet.getValueFormatter();
              if (valueFormatter) {
                this.drawValue(c, valueFormatter, val, entry, i, x,
                    val >= 0 ?
                    (buffer.buffer[j + 1] + posOffset) :
                    (buffer.buffer[j + 3] + negOffset),
                  dataSet.getValueTextColor(j / 4));
              }
            }
            let icon: ChartPixelMap | null = entry.getIcon();
            if (icon && dataSet.isDrawIconsEnabled()) {

              let px: number = x;
              let py: number = val >= 0 ?
                (buffer.buffer[j + 1] + posOffset) :
                (buffer.buffer[j + 3] + negOffset);

              px += iconsOffset.x;
              py += iconsOffset.y;

              Utils.drawImage(
                c,
                icon,
                Utils.parseInt(px),
                Utils.parseInt(py),
                icon.getWidth(),
                icon.getHeight());
            }
          }

          // if we have stacks
        } else {

          let trans: Transformer | null = this.mChart.getTransformer(dataSet.getAxisDependency());

          let bufferIndex: number = 0;
          let index: number = 0;

          while (index < dataSet.getEntryCount() * (this.mAnimator ? this.mAnimator.getPhaseX() : 1)) {

            let entry: BarEntry = dataSet.getEntryForIndex(index);

            let vals: number[] | null = entry.getYVals();
            let x: number = (buffer.buffer[bufferIndex] + buffer.buffer[bufferIndex + 2]) / 2;

            let color: number = dataSet.getValueTextColor(index);

            // we still draw stacked bars, but there is one
            // non-stacked
            // in between
            if (vals == null) {

              if (!this.mViewPortHandler || !this.mViewPortHandler.isInBoundsRight(x))
                break;

              if (!this.mViewPortHandler || !this.mViewPortHandler.isInBoundsY(buffer.buffer[bufferIndex + 1])
              || !this.mViewPortHandler.isInBoundsLeft(x))
                continue;

              if (dataSet.isDrawValuesEnabled()) {
                let valueFormatter: IValueFormatter | null = dataSet.getValueFormatter();
                if (valueFormatter) {
                  this.drawValue(c, valueFormatter, entry.getY(), entry, i, x,
                    buffer.buffer[bufferIndex + 1] +
                    (entry.getY() >= 0 ? posOffset : negOffset),
                    color);
                }
              }

              let icon: ChartPixelMap | null = entry.getIcon();
              if (icon && dataSet.isDrawIconsEnabled()) {
                let px: number = x;
                let py: number = buffer.buffer[bufferIndex + 1] +
                (entry.getY() >= 0 ? posOffset : negOffset);

                px += iconsOffset.x;
                py += iconsOffset.y;

                Utils.drawImage(
                  c,
                  icon,
                  Utils.parseInt(px),
                  Utils.parseInt(py),
                  icon.getWidth(),
                  icon.getHeight());
              }

              // draw stack values
            }

            else {

              let transformed: number[] = new Array<number>(vals.length * 2);
              let posY: number = 0;
              let negY: number = -entry.getNegativeSum();
              for (let k = 0, idx = 0; k < transformed.length; k += 2, idx++) {

                let value: number = vals[idx];
                let y: number = 0;
                if (value == 0.0 && (posY == 0.0 || negY == 0.0)) {
                  // Take care of the situation of a 0.0 value, which overlaps a non-zero bar
                  y = value;
                } else if (value >= 0.0) {
                  posY += value;
                  y = posY;
                } else {
                  y = negY;
                  negY -= value;
                }

                transformed[k + 1] = y * phaseY;
              }
              if (trans) {
                trans.pointValuesToPixel(transformed);
              }


              for (let k = 0; k < transformed.length; k += 2) {

                const val: number = vals[k / 2];
                const drawBelow: boolean = (val == 0.0 && negY == 0.0 && posY > 0.0) || val < 0.0;
                let y: number = transformed[k + 1] + (drawBelow ? negOffset : posOffset);

                if (!this.mViewPortHandler || !this.mViewPortHandler.isInBoundsRight(x))
                  break;

                if (!this.mViewPortHandler || !this.mViewPortHandler.isInBoundsY(y)
                || !this.mViewPortHandler.isInBoundsLeft(x))
                  continue;

                if (dataSet.isDrawValuesEnabled()) {
                  let valueFormatter: IValueFormatter | null = dataSet.getValueFormatter();
                  if (valueFormatter) {
                    this.drawValue(c,
                      valueFormatter,
                      vals[k / 2],
                      entry,
                      i,
                      x,
                      y,
                      color);
                  }
                }
                let icon: ChartPixelMap | null = entry.getIcon();
                if (icon && dataSet.isDrawIconsEnabled()) {
                  Utils.drawImage(
                    c,
                    icon,
                    Number(x + iconsOffset.x),
                    Number(y + iconsOffset.y),
                    icon.getWidth(),
                    icon.getHeight());
                }
              }
            }

            bufferIndex = vals == null ? bufferIndex + 4 : bufferIndex + 4 * vals.length;
            index++;
          }
        }

        MPPointF.recycleInstance(iconsOffset);
      }
    }
  }

  // @Override
  public drawHighlighted(c: CanvasRenderingContext2D, indices: Highlight[]): void {
    if (!this.mChart) {
      return;
    }
    let barData: BarData | null = this.mChart.getBarData();
    if (!barData) {
      return;
    }

    for (let i = 0; i < indices.length; i++) {
      let high: Highlight = indices[i];
      let set: IBarDataSet | null = barData.getDataSetByIndex(high.getDataSetIndex());

      if (set == null || !set.isHighlightEnabled())
        continue;

      let e: BarEntry | null = set.getEntryForXValue(high.getX(), high.getY());
      if (!e) {
        continue;
      }
      if (!this.isInBoundsX(e, set))
        continue;

      let trans: Transformer | null = this.mChart.getTransformer(set.getAxisDependency());
      let highLightColor: number = set.getHighLightColor();
      if (highLightColor == 0) {
        highLightColor = Color.Black
      }
      this.mHighlightPaint.setColor(highLightColor);
      this.mHighlightPaint.setGlobalAlpha(set.getHighLightAlpha() / 255);

      let isStack: boolean = (high.getStackIndex() >= 0 && e.isStacked()) ? true : false;

      let y1: number = 0;
      let y2: number = 0;

      let drawRadius: boolean = false;
      let radius = barData.getTopRadius();

      if (isStack) {

        if (this.mChart.isHighlightFullBarEnabled()) {

          y1 = e.getPositiveSum();
          y2 = -e.getNegativeSum();

        } else {
          let dataRanges: Range[] | null = e.getRanges();
          if (dataRanges) {
            let range: Range = dataRanges[high.getStackIndex()];
            //堆叠柱状图顶部的柱形绘制圆角
            if(radius != 0 && high.getStackIndex() == dataRanges.length - 1){
              drawRadius = true;
            }
            y1 = range.myfrom;
            y2 = range.to;
          }
        }
      } else {
        if (radius != 0) {
          drawRadius = true;
        }
        y1 = e.getY();
        y2 = 0.0;
      }
      if (trans) {
        this.prepareBarHighlight(e.getX(), y1, y2, barData.getBarWidth() / 2, trans);
      }

      // 圆角位置
      let cornerType: RoundCornerType = 'up'
      // 当前图表是否反向
      let isInverted: boolean = this.mChart.isInverted(set.getAxisDependency())

      if (isInverted) {
        cornerType = e.getY() > 0 ? 'down' : 'up'
      } else {
        cornerType = e.getY() > 0 ? 'up' : 'down'
      }

      this.setHighlightDrawPos(high, this.mBarRect);
      Utils.drawFillRect(drawRadius, c, this.mHighlightPaint, this.mBarRect.left, this.mBarRect.top, this.mBarRect.right, this.mBarRect.bottom, radius, cornerType);
    }

  }

  /**
   * Sets the drawing position of the highlight object based on the riven bar-rect.
   * @param high
   */
  protected setHighlightDrawPos(high: Highlight, bar: MyRect): void {
    high.setDraw(bar.centerX(), bar.top);
  }

  // @Override
  public drawExtras(c: CanvasRenderingContext2D): void {
  }
}
