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

import RadarChart from '../charts/RadarChartModel';
import { XAxis } from '../components/XAxis';
import MPPointF from '../utils/MPPointF';
import Transformer from '../utils/Transformer';
import Utils from '../utils/Utils';
import ViewPortHandler from '../utils/ViewPortHandler';
import XAxisRenderer from './XAxisRenderer';

export default class XAxisRendererRadarChart extends XAxisRenderer {
  public mChart: RadarChart;

  constructor(viewPortHandler: ViewPortHandler, xAxis: XAxis, chart: RadarChart, trans?: Transformer) {
    super(viewPortHandler, xAxis, trans);
    this.mChart = chart;
  }

  public renderAxisLabels(c: CanvasRenderingContext2D) {
    if (this.mChart == null || this.mChart.getData() == null || !this.mXAxis || !this.mXAxis.isEnabled() || !this.mXAxis.isDrawLabelsEnabled()) {
      return;
    }

    const labelRotationAngleDegrees: number = this.mXAxis.getLabelRotationAngle();
    const drawLabelAnchor: MPPointF = MPPointF.getInstance(0.5, 0.25);

    if (this.mXAxis && this.mAxisLabelPaint) {
      this.mAxisLabelPaint.setFontFamily(this.mXAxis.getTypeface());
      this.mAxisLabelPaint.setTextSize(this.mXAxis.getTextSize());
      this.mAxisLabelPaint.setColor(this.mXAxis.getTextColor());

      let sliceangle: number = this.mChart.getSliceAngle();

      let factor: number = this.mChart.getFactor();

      let center: MPPointF | null = this.mChart.getCenterOffsets();
      let pOut: MPPointF = MPPointF.getInstance(0, 0);
      // let extraWidth=Utils.calcTextWidth(this.mAxisLabelPaint,this.mXAxis.longest);
      // let r:number =  this.mChart.getYRange() * factor+extraWidth/2+3;
      let maxCountEntrySet = this.mChart!.getData()!.getMaxEntryCountSet();
      if (maxCountEntrySet) {
        for (let i = 0; i < maxCountEntrySet.getEntryCount(); i++) {
          if (this.mAxis != null && this.mXAxis != undefined) {
            let label: string = this.mXAxis.getValueFormatter().getFormattedValue(i, this.mXAxis);
            let angle: number = (sliceangle * i + this.mChart.getRotationAngle()) % 360;
            if (center && this.mXAxis) {
              pOut = Utils.getPosition(center, this.mChart.getYRange() * factor + this.mXAxis.mLabelRotatedWidth / 2, angle, pOut);
            }

            if (this.mXAxis) {
              this.drawLabel(c, label, pOut.x, pOut.y - this.mXAxis.mLabelRotatedHeight / 2.0,
                drawLabelAnchor, labelRotationAngleDegrees);
            }
          }
        }
      }

      if (center) {
        MPPointF.recycleInstance(center);
      }
      MPPointF.recycleInstance(pOut);
      MPPointF.recycleInstance(drawLabelAnchor);
    }
  }

  /**
   * XAxis LimitLines on RadarChart not yet supported.
   *
   * @param c
   */
  public renderLimitLines(c: CanvasRenderingContext2D) {
    // this space intentionally left blank
  }
}
