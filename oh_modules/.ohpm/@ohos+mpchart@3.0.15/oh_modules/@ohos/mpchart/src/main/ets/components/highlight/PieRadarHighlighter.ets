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

import PieRadarChartBase from '../charts/PieRadarChartBaseModel';
import ChartData from '../data/ChartData';
import EntryOhos from '../data/EntryOhos';
import IDataSet from '../interfaces/datasets/IDataSet';
import Highlight from './Highlight';
import IHighlighter from './IHighlighter';

export default abstract class PieRadarHighlighter<T extends PieRadarChartBase<ChartData<IDataSet<EntryOhos>>>> implements IHighlighter {
  protected mChart: T;
  /**
   * buffer for storing previously highlighted values
   */
  protected mHighlightBuffer: Array<Highlight> = new Array<Highlight>();

  constructor(chart: T) {
    this.mChart = chart;
  }

  public getHighlight(x: number, y: number): Highlight | null {
    if (this.mChart == null || this.mChart.getData() == null || this.mChart.getData()!.getMaxEntryCountSet() == null) {
      return null;
    }

    let touchDistanceToCenter: number = this.mChart.distanceToCenter(x, y);

    // check if a slice was touched
    if (touchDistanceToCenter > this.mChart.getRadius()) {

      // if no slice was touched, highlight nothing
      return null;

    } else {

      let angle: number = this.mChart.getAngleForPoint(x, y);

      // if (this.mChart instanceof PieChartModel) {
      //   let animator = this.mChart.getAnimator();
      //   if(animator){
      //     angle /= animator.getPhaseY();
      //   }
      // }

      let index = this.mChart.getIndexForAngle(angle);

      // check if the index could be found
      if (index < 0 || index >= this.mChart!.getData()!.getMaxEntryCountSet()!.getEntryCount()) {
        return null;

      } else {
        return this.getClosestHighlight(index, x, y);
      }
    }
  }

  /**
   * Returns the closest Highlight object of the given objects based on the touch position inside the chart.
   *
   * @param index
   * @param x
   * @param y
   * @return
   */
  protected abstract getClosestHighlight(index: number, x: number, y: number): Highlight | null;
}