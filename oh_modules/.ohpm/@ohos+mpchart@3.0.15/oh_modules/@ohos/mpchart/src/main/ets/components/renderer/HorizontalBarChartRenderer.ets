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

import { ChartInterface, ChartPixelMap, Highlight, IValueFormatter, MPPointF } from '../../../../..';

import ChartAnimator from '../animation/ChartAnimator';
import BarBuffer from '../buffer/BarBuffer';
import HorizontalBarBuffer from '../buffer/HorizontalBarBuffer';
import BarData from '../data/BarData';
import BarEntry from '../data/BarEntry';
import MyRect from '../data/Rect';
import BarDataProvider from '../interfaces/dataprovider/BarDataProvider';
import IBarDataSet from '../interfaces/datasets/IBarDataSet';
import Fill, { FillDirection } from '../utils/Fill';
import { JArrayList } from '../utils/JArrayList';
import Transformer from '../utils/Transformer';
import Utils from '../utils/Utils';
import ViewPortHandler from '../utils/ViewPortHandler';
import BarChartRenderer from './BarChartRenderer';
import HashMap from '@ohos.util.HashMap';

export default class HorizontalBarChartRenderer extends BarChartRenderer {
  textSizeCache = new HashMap<string, TextMetrics>();

  constructor(chart: BarDataProvider, animator: ChartAnimator, viewPortHandler: ViewPortHandler) {
    super(chart, animator, viewPortHandler);
    this.mValuePaint.setTextAlign('left');
  }

  initBuffers() {
    if (!this.mChart) {
      return;
    }
    let barData: BarData | null = this.mChart.getBarData();
    if (!barData) {
      return;
    }
    this.mBarBuffers = new Array<HorizontalBarBuffer>(barData.getDataSetCount());
    for (let i = 0; i < this.mBarBuffers.length; i++) {
      let set: IBarDataSet | null = barData.getDataSetByIndex(i);
      if (set) {
        this.mBarBuffers[i] = new HorizontalBarBuffer(set.getEntryCount() * 4 * (set.isStacked() ? set.getStackSize() : 1),
          barData.getDataSetCount(), set.isStacked());
      }
    }
  }

  drawDataSet(c: CanvasRenderingContext2D, dataSet: IBarDataSet, index: number) {
    if (!this.mChart || !this.mChart.getBarData() || !this.mViewPortHandler || !this.mAnimator) {
      return;
    }
    let trans: Transformer | null = this.mChart.getTransformer(dataSet.getAxisDependency());
    this.mBarBorderPaint?.setColor(dataSet.getBarBorderColor());
    this.mBarBorderPaint?.setStrokeWidth(Utils.handleDataValues(dataSet.getBarBorderWidth()));

    const drawBorder: boolean = dataSet.getBarBorderWidth() > 0;

    let phaseX = this.mAnimator.getPhaseX();
    let phaseY = this.mAnimator.getPhaseY();

    // draw the bar shadow before the values
    if (this.mChart.isDrawBarShadowEnabled()) {
      this.mShadowPaint?.setColor(dataSet.getBarShadowColor());

      let barData: BarData | null = this.mChart.getBarData();

      if (!barData) {
        return;
      }
      const barWidth: number = barData.getBarWidth();
      const barWidthHalf: number = barWidth / 2;
      let x = 0;

      if (this.mShadowPaint) {
        Utils.resetContext2DWithoutFont(c, this.mShadowPaint);
      }
      for (let i = 0,
        count = Math.min((Math.ceil((dataSet.getEntryCount()) * phaseX)), dataSet.getEntryCount());
           i < count;
           i++) {

        let e: BarEntry = dataSet.getEntryForIndex(i);

        x = e.getX();

        this.mBarShadowRectBuffer.top = x - barWidthHalf;
        this.mBarShadowRectBuffer.bottom = x + barWidthHalf;

        trans?.rectValueToPixel(this.mBarShadowRectBuffer);

        if (!this.mViewPortHandler.isInBoundsTop(this.mBarShadowRectBuffer.bottom)) {
          continue;
        }
        if (!this.mViewPortHandler.isInBoundsBottom(this.mBarShadowRectBuffer.top)) {
          break;
        }

        this.mBarShadowRectBuffer.left = this.mViewPortHandler.contentLeft();
        this.mBarShadowRectBuffer.right = this.mViewPortHandler.contentRight();


        if (this.mShadowPaint) {
          c.beginPath();
          c.rect(this.mBarShadowRectBuffer.left, this.mBarShadowRectBuffer.top, this.mBarShadowRectBuffer.width(), this.mBarShadowRectBuffer.height());
          c.fill();
          c.closePath();
        }
      }
    }

    let buffer: BarBuffer = this.mBarBuffers[index];
    buffer.setPhases(phaseX, phaseY);
    buffer.setDataSet(index);
    buffer.setInverted(this.mChart.isInverted(dataSet.getAxisDependency()));
    buffer.setBarWidth(this.mChart.getBarData()!.getBarWidth());

    buffer.feed(dataSet);

    trans?.pointValuesToPixel(buffer.buffer);

    const isCustomFill: boolean = dataSet.getFills() != null && !dataSet.getFills()!.isEmpty();
    const isSingleColor: boolean = dataSet.getColors().size() == 1;
    const isInverted: boolean = this.mChart.isInverted(dataSet.getAxisDependency());

    if (isSingleColor) {
      this.mRenderPaint.setColor(dataSet.getColor());
    }

    for (let j = 0, pos = 0; j < buffer.size(); j += 4, pos++) {

      if (!this.mViewPortHandler.isInBoundsTop(buffer.buffer[j + 3]))
        break;

      if (!this.mViewPortHandler.isInBoundsBottom(buffer.buffer[j + 1]))
        continue;

      if (!isSingleColor) {
        // Set the color for the currently drawn value. If the index
        // is out of bounds, reuse colors.
        this.mRenderPaint.setColor(dataSet.getColor(j / 4));
      }
      let left = buffer.buffer[j];
      let top = buffer.buffer[j + 1];
      let right = buffer.buffer[j + 2];
      let bottom = buffer.buffer[j + 3];

      if (isCustomFill) {
        dataSet.getFill(pos)?.fillRect(
          c, this.mRenderPaint,
          left,
          top,
          right,
          bottom,
            isInverted ? FillDirection.LEFT : FillDirection.RIGHT);
      }
      else {
        Utils.resetContext2DWithoutFont(c, this.mRenderPaint);
        c.beginPath();
        c.rect(left, top, right - left, bottom - top);
        c.fill();
        c.closePath();
      }

      if (drawBorder && this.mBarBorderPaint) {
        Utils.resetContext2DWithoutFont(c, this.mBarBorderPaint);
        c.beginPath();
        c.rect(left, top, right - left, bottom - top);
        c.stroke();
        c.closePath();
      }
    }
  }

  drawValues(c: CanvasRenderingContext2D) {
    if (!this.mChart || !this.mViewPortHandler || !this.mAnimator) {
      return;
    }
    let chartData = this.mChart.getBarData();
    if (!chartData) {
      return;
    }
    if (this.isDrawingValuesAllowed(this.mChart)) {

      let dataSets: JArrayList<IBarDataSet> = chartData.getDataSets();

      const valueOffsetPlus: number = Utils.handleDataValues(5);
      let posOffset: number = 0;
      let negOffset: number = 0;
      const drawValueAboveBar: boolean = this.mChart.isDrawValueAboveBarEnabled();
      let halfTextHeight: number = Utils.getLabelTextSize(this.mValuePaint, "10", this.textSizeCache).height / 2;
      for (let i = 0; i < chartData.getDataSetCount(); i++) {

        let dataSet: IBarDataSet = dataSets.get(i);

        if (!this.shouldDrawValues(dataSet)) {
          continue;
        }

        let isInverted: boolean = this.mChart.isInverted(dataSet.getAxisDependency());

        // apply the text-styling defined by the DataSet
        this.applyValueTextStyle(dataSet);

        let formatter: IValueFormatter | null = dataSet.getValueFormatter();

        // get the buffer
        let buffer: BarBuffer = this.mBarBuffers[i];

        let phaseY: number = this.mAnimator.getPhaseY();

        let iconsOffset: MPPointF = MPPointF.getInstance(undefined, undefined, dataSet.getIconsOffset());
        iconsOffset.x = Utils.handleDataValues(iconsOffset.x);
        iconsOffset.y = Utils.handleDataValues(iconsOffset.y);

        // if only single values are drawn (sum)
        if (!dataSet.isStacked()) {

          for (let j = 0; j < buffer.buffer.length * this.mAnimator.getPhaseX(); j += 4) {

            let y: number = (buffer.buffer[j + 1] + buffer.buffer[j + 3]) / 2;

            if (!this.mViewPortHandler.isInBoundsTop(buffer.buffer[j + 1])) {
              break;
            }

            if (!this.mViewPortHandler.isInBoundsX(buffer.buffer[j])) {
              continue;
            }

            if (!this.mViewPortHandler.isInBoundsBottom(buffer.buffer[j + 1])) {
              continue;
            }

            let entry: BarEntry = dataSet.getEntryForIndex(j / 4);
            let val: number = entry.getY();
            let formattedValue: string = "";

            if (formatter) {
              formattedValue = formatter.getFormattedValue(val, entry, i, this.mViewPortHandler);
            }

            // calculate the correct offset depending on the draw position of the value
            let valueTextWidth: number = Utils.getLabelTextSize(this.mValuePaint, formattedValue, this.textSizeCache)
              .width;
            posOffset = (drawValueAboveBar ? valueOffsetPlus : -(valueTextWidth + valueOffsetPlus));
            negOffset = (drawValueAboveBar ? -(valueTextWidth + valueOffsetPlus) : valueOffsetPlus)
            - (buffer.buffer[j + 2] - buffer.buffer[j]);

            if (isInverted) {
              posOffset = -posOffset - valueTextWidth;
              negOffset = -negOffset - valueTextWidth;
            }

            if (dataSet.isDrawValuesEnabled()) {
              this.drawHorizontalValue(c,
                formattedValue,
                buffer.buffer[j + 2] + (val >= 0 ? posOffset : negOffset),
                y + halfTextHeight,
                dataSet.getValueTextColor(j / 2));
            }

            if (entry.getIcon() != null && dataSet.isDrawIconsEnabled()) {

              let icon: ChartPixelMap | null = entry.getIcon();

              let px: number = buffer.buffer[j + 2] + (val >= 0 ? posOffset : negOffset);
              let py: number = y;

              px += iconsOffset.x;
              py += iconsOffset.y;

              if (icon) {
                Utils.drawImage(
                  c,
                  icon,
                  Math.floor(px),
                  Math.floor(py),
                  icon.getWidth(),
                  icon.getHeight());
              }
            }
          }
          // if each value of a potential stack should be drawn
        } else {
          if (!this.mChart) {
            return;
          }

          let trans: Transformer | null = this.mChart.getTransformer(dataSet.getAxisDependency());

          let bufferIndex = 0;
          let index = 0;

          while (index < dataSet.getEntryCount() * this.mAnimator.getPhaseX()) {

            let entry: BarEntry = dataSet.getEntryForIndex(index);

            let color: number = dataSet.getValueTextColor(index);
            let vals: number[] | null = entry.getYVals();

            // we still draw stacked bars, but there is one
            // non-stacked
            // in between
            if (vals == null) {
              if (!this.mViewPortHandler.isInBoundsTop(buffer.buffer[bufferIndex + 1])) {
                break;
              }

              if (!this.mViewPortHandler.isInBoundsX(buffer.buffer[bufferIndex])) {
                continue;
              }

              if (!this.mViewPortHandler.isInBoundsBottom(buffer.buffer[bufferIndex + 1])) {
                continue;
              }

              let val: number = entry.getY();
              let formattedValue: string = "";
              if (formatter) {
                formattedValue = formatter.getFormattedValue(val, entry, i, this.mViewPortHandler);
              }

              // calculate the correct offset depending on the draw position of the value
              let valueTextWidth: number = Utils.getLabelTextSize(this.mValuePaint, formattedValue, this.textSizeCache)
                .width;
              posOffset = (drawValueAboveBar ? valueOffsetPlus : -(valueTextWidth + valueOffsetPlus));
              negOffset = (drawValueAboveBar ? -(valueTextWidth + valueOffsetPlus) : valueOffsetPlus);

              if (isInverted) {
                posOffset = -posOffset - valueTextWidth;
                negOffset = -negOffset - valueTextWidth;
              }

              if (dataSet.isDrawValuesEnabled()) {
                this.drawHorizontalValue(c, formattedValue,
                  buffer.buffer[bufferIndex + 2]
                  + (entry.getY() >= 0 ? posOffset : negOffset),
                  buffer.buffer[bufferIndex + 1] + halfTextHeight, color);
              }

              if (entry.getIcon() != null && dataSet.isDrawIconsEnabled()) {

                let icon: ChartPixelMap | null = entry.getIcon();

                let px: number = buffer.buffer[bufferIndex + 2]
                + (entry.getY() >= 0 ? posOffset : negOffset);
                let py: number = buffer.buffer[bufferIndex + 1];

                px += iconsOffset.x;
                py += iconsOffset.y;

                if (icon) {
                  Utils.drawImage(
                    c,
                    icon,
                    Math.floor(px),
                    Math.floor(py),
                    icon.getWidth(),
                    icon.getHeight());
                }
              }
            } else {
              let transformed: number[] = new Array<number>(vals.length * 2);

              let posY: number = 0;
              let negY: number = -entry.getNegativeSum();

              for (let k = 0, idx = 0; k < transformed.length; k += 2, idx++) {
                let value: number = vals[idx];
                let y: number = 0;

                if (value == 0 && (posY == 0 || negY == 0)) {
                  // Take care of the situation of a 0.0 value, which overlaps a non-zero bar
                  y = value;
                } else if (value >= 0) {
                  posY += value;
                  y = posY;
                } else {
                  y = negY;
                  negY -= value;
                }

                transformed[k] = y * phaseY;
              }

              trans?.pointValuesToPixel(transformed);

              for (let k = 0; k < transformed.length; k += 2) {
                const val: number = vals[k/2];
                let formattedValue: string = "";
                if (formatter) {
                  formattedValue = formatter.getFormattedValue(val, entry, i, this.mViewPortHandler);
                }

                // calculate the correct offset depending on the draw position of the value
                let valueTextWidth: number = Utils.getLabelTextSize(this.mValuePaint, formattedValue, this.textSizeCache)
                  .width;
                posOffset = (drawValueAboveBar ? valueOffsetPlus : -(valueTextWidth + valueOffsetPlus));
                negOffset = (drawValueAboveBar ? -(valueTextWidth + valueOffsetPlus) : valueOffsetPlus);

                if (isInverted) {
                  posOffset = -posOffset - valueTextWidth;
                  negOffset = -negOffset - valueTextWidth;
                }

                const drawBelow: boolean = (val == 0 && negY == 0 && posY > 0) ||
                val < 0;

                let x = transformed[k] + (drawBelow ? negOffset : posOffset);
                let y = (buffer.buffer[bufferIndex + 1] + buffer.buffer[bufferIndex + 3]) / 2;

                if (!this.mViewPortHandler.isInBoundsTop(y)) {
                  break;
                }

                if (!this.mViewPortHandler.isInBoundsX(x)) {
                  continue;
                }

                if (!this.mViewPortHandler.isInBoundsBottom(y)) {
                  continue;
                }

                if (dataSet.isDrawValuesEnabled()) {
                  this.drawHorizontalValue(c, formattedValue, x, y + halfTextHeight, color);
                }

                if (entry.getIcon() != null && dataSet.isDrawIconsEnabled()) {
                  let icon: ChartPixelMap | null = entry.getIcon();
                  if (icon) {
                    Utils.drawImage(
                      c,
                      icon,
                      Math.floor(x+iconsOffset.x),
                      Math.floor(y+iconsOffset.y),
                      icon.getWidth(),
                      icon.getHeight());
                  }
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

  drawHorizontalValue(c: CanvasRenderingContext2D, valueText: string, x: number, y: number, color: number) {
    this.mValuePaint.setColor(color);
    Utils.resetContext2DWithoutLine(c, this.mValuePaint);
    c.beginPath();
    c.fillText(valueText, x, y);
    c.closePath();
  }

  prepareBarHighlight(x: number, y1: number, y2: number, barWidthHalf: number, trans: Transformer): void {
    let top = x - barWidthHalf;
    let bottom = x + barWidthHalf;
    let left = y1;
    let right = y2;

    this.mBarRect.set(left, top, right, bottom);
    trans.rectToPixelPhaseHorizontal(this.mBarRect, this.mAnimator ? this.mAnimator.getPhaseY() : 0);
  }

  setHighlightDrawPos(high: Highlight, bar: MyRect) {
    high.setDraw(bar.centerY(), bar.right);
  }

  isDrawingValuesAllowed(chart: ChartInterface) {
    let chartData = chart.getData();
    if (chartData && this.mViewPortHandler) {
      return chartData.getEntryCount() < chart.getMaxVisibleCount()
      * this.mViewPortHandler.getScaleY();
    } else {
      return false;
    }
  }
}