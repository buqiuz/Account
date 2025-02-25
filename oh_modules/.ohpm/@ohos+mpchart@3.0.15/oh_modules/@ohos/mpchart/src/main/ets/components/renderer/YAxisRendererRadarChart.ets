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

import LimitLine from '../components/LimitLine';
import MPPointF from '../utils/MPPointF';
import Utils from '../utils/Utils';
import YAxisRenderer from '../renderer/YAxisRenderer';
import { JArrayList } from '../utils/JArrayList';
import RadarChart from '../charts/RadarChartModel';
import ViewPortHandler from '../utils/ViewPortHandler';
import YAxis from '../components/YAxis';
import Transformer from '../utils/Transformer';

export default class YAxisRendererRadarChart extends YAxisRenderer {
  public mChart: RadarChart;

  constructor(viewPorthandler: ViewPortHandler, yAxis: YAxis, chart: RadarChart, trans?: Transformer) {
    super(viewPorthandler, yAxis, trans);
    this.mChart = chart;
  }

  protected computeAxisValues(min: number, max: number): void {
    if (!this.mYAxis || !this.mAxis) {
      return;
    }
    let yMin: number = min;
    let yMax: number = max;

    let labelCount: number = this.mAxis.getLabelCount();
    let range: number = Math.abs(yMax - yMin);

    if (labelCount == 0 || range <= 0 || range == Number.POSITIVE_INFINITY) {
      this.mAxis.mEntries = [];
      this.mAxis.mCenteredEntries = [];
      this.mAxis.mEntryCount = 0;
      return;
    }

    // Find out how much spacing (in y value space) between axis values
    let rawInterval: number = range / labelCount;
    let interval: number = Utils.roundToNextSignificant(rawInterval);

    // If granularity is enabled, then do not allow the interval to go below specified granularity.
    // This is used to avoid repeated values when rounding values for display.
    if (this.mAxis.isGranularityEnabled())
      interval = interval < this.mAxis.getGranularity() ? this.mAxis.getGranularity() : interval;

    // Normalize interval
    let intervalMagnitude: number = Utils.roundToNextSignificant(Math.pow(10, Math.log10(interval)));
    let intervalSigDigit = interval / intervalMagnitude;
    if (intervalSigDigit > 5) {
      // Use one order of magnitude higher, to avoid intervals like 0.9 or 90
      // if it's 0.0 after floor(), we use the old value
      interval = Math.floor(10.0 * intervalMagnitude) == 0.0
        ? interval
        : Math.floor(10.0 * intervalMagnitude);
    }

    let centeringEnabled: boolean = this.mAxis.isCenterAxisLabelsEnabled();
    let n = centeringEnabled ? 1 : 0;

    // force label count
    if (this.mAxis.isForceLabelsEnabled()) {

      let step: number = range / (labelCount - 1);
      this.mAxis.mEntryCount = labelCount;

      if (this.mAxis.mEntries.length < labelCount) {
        // Ensure stops contains at least numStops elements.
        this.mAxis.mEntries = new Array(labelCount);
      }

      let v: number = min;

      for (let i = 0; i < labelCount; i++) {
        this.mAxis.mEntries[i] = v;
        v += step;
      }

      n = labelCount;

      // no forced count
    } else {

      let first: number = interval == 0.0 ? 0.0 : Math.ceil(yMin / interval) * interval;
      if (centeringEnabled) {
        first -= interval;
      }

      let last: number = interval == 0.0 ? 0.0 : Utils.nextUp(Math.floor(yMax / interval) * interval);

      let f: number;
      let i: number;

      if (interval != 0.0) {
        for (f = first; f <= last; f += interval) {
          ++n;
        }
      }

      n++;

      this.mAxis.mEntryCount = n;

      if (this.mAxis.mEntries.length < n) {
        // Ensure stops contains at least numStops elements.
        this.mAxis.mEntries = new Array(n);
      }

      for (f = first, i = 0; i < n; f += interval, ++i) {

        if (f == 0.0) // Fix for negative zero case (Where value == -0.0, and 0.0 == -0.0)
          f = 0.0;

        this.mAxis.mEntries[i] = f;
      }
    }

    // set decimals
    if (interval < 1) {
      this.mAxis.mDecimals = Math.ceil(-Math.log10(interval));
    } else {
      this.mAxis.mDecimals = 0;
    }

    if (centeringEnabled) {

      if (this.mAxis.mCenteredEntries.length < n) {
        this.mAxis.mCenteredEntries = new Array(n);
      }

      let offset: number = (this.mAxis.mEntries[1] - this.mAxis.mEntries[0]) / 2;

      for (let i = 0; i < n; i++) {
        this.mAxis.mCenteredEntries[i] = this.mAxis.mEntries[i] + offset;
      }
    }
    this.mAxis.mAxisMinimum = this.mAxis.mEntries[0];
    this.mAxis.mAxisMaximum = this.mAxis.mEntries[n-1];
    this.mAxis.mAxisRange = Math.abs(this.mAxis.mAxisMaximum - this.mAxis.mAxisMinimum);
  }

  public renderAxisLabels(c: CanvasRenderingContext2D) {

    if (!this.mYAxis || !this.mYAxis.isEnabled() || !this.mYAxis.isDrawLabelsEnabled())
      return;
    if (this.mAxisLabelPaint) {
      this.mAxisLabelPaint.setFontFamily(this.mYAxis.getTypeface());
      this.mAxisLabelPaint.setTextSize(this.mYAxis.getTextSize());
      this.mAxisLabelPaint.setColor(this.mYAxis.getTextColor());
    }

    let center: MPPointF | null = this.mChart.getCenterOffsets();
    let pOut: MPPointF = MPPointF.getInstance(0, 0);
    let factor: number = this.mChart.getFactor();

    const myFrom: number = this.mYAxis.isDrawBottomYLabelEntryEnabled() ? 0 : 1;
    const to = this.mYAxis.isDrawTopYLabelEntryEnabled()
      ? this.mYAxis.mEntryCount
      : (this.mYAxis.mEntryCount - 1);

    const xOffset = this.mYAxis.getLabelXOffset();

    for (let j = myFrom; j < to; j++) {

      let r: number = (this.mYAxis.mEntries[j] - this.mYAxis.mAxisMinimum) * factor;
      if (center) {
        pOut = Utils.getPosition(center, r, this.mChart.getRotationAngle(), pOut);
      }

      let label: string = this.mYAxis.getFormattedLabel(j);

      //c.drawText(label, pOut.x + xOffset, pOut.y, mAxisLabelPaint);
      Utils.resetContext2DWithoutLine(c, this.mAxisLabelPaint);
      c.beginPath();
      c.strokeText(label, pOut.x + xOffset, pOut.y);
      c.closePath();
    }
    if (center) {
      MPPointF.recycleInstance(center);
    }
    MPPointF.recycleInstance(pOut);
  }

  private mRenderLimitLinesPathBuffer: string = ''

  public renderLimitLines(c: CanvasRenderingContext2D) {
    if (!this.mYAxis) {
      return;
    }
    let limitLines: JArrayList<LimitLine> = this.mYAxis.getLimitLines();

    if (limitLines == null)
      return;

    let sliceangle: number = this.mChart.getSliceAngle();

    // calculate the factor that is needed for transforming the value to
    // pixels
    let factor: number = this.mChart.getFactor();

    let center: MPPointF | null = this.mChart.getCenterOffsets();
    let pOut: MPPointF = MPPointF.getInstance(0, 0);
    for (let i = 0; i < limitLines.size(); i++) {

      let l: LimitLine = limitLines.get(i);

      if (!l.isEnabled())
        continue;

      if (this.mLimitLinePaint) {
        this.mLimitLinePaint.setColor(l.getLineColor());
        if (l.getDashPathEffect()) {
          this.mLimitLinePaint.setDashPathEffect(l.getDashPathEffect());
        }

        this.mLimitLinePaint.setStrokeWidth(l.getLineWidth());

      }

      let r: number = (l.getLimit() - this.mChart.getYChartMin()) * factor;

      this.mRenderLimitLinesPathBuffer;
      //limitPath.reset();

      if (this.mChart) {
        let modeData = this.mChart.getData();
        if (modeData) {
          let entrySet = modeData.getMaxEntryCountSet();
          if (entrySet) {
            for (let j = 0; j < entrySet.getEntryCount(); j++) {
              if (center) {
                pOut = Utils.getPosition(center, r, sliceangle * j + this.mChart.getRotationAngle(), pOut);
              }

              //                if (j == 0)
              //                    limitPath.moveTo(pOut.x, pOut.y);
              //                else
              //                    limitPath.lineTo(pOut.x, pOut.y);
            }
          }
        }
      }


      //c.drawPath(limitPath, mLimitLinePaint);
    }
    if (center) {
      MPPointF.recycleInstance(center);
    }
    MPPointF.recycleInstance(pOut);
  }
}
