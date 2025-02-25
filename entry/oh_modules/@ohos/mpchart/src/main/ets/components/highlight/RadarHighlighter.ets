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
import EntryOhos from '../data/EntryOhos';
import IDataSet from '../interfaces/datasets/IDataSet';
import MPPointF from '../utils/MPPointF';
import Utils from '../utils/Utils';
import Highlight from './Highlight';
import PieRadarHighlighter from './PieRadarHighlighter';

export default class RadarHighlighter extends PieRadarHighlighter<RadarChart> {
  constructor(chart: RadarChart) {
    super(chart);
  }

  protected getClosestHighlight(index: number, x: number, y: number): Highlight | null {
    const highlights = this.getHighlightsAtIndex(index);

    const distanceToCenter = this.mChart.distanceToCenter(x, y) / this.mChart.getFactor();

    let closest: Highlight | null = null;
    let distance = Number.MAX_VALUE;

    for (let i = 0; i < highlights.length; i++) {
      const high = highlights[i];

      const cdistance = Math.abs(high.getY() - distanceToCenter);

      if (cdistance < distance) {
        closest = high;
        distance = cdistance;
      }
    }

    return closest;
  }

  /**
   * Returns an array of Highlight objects for the given index. The Highlight
   * objects give information about the value at the selected index and the
   * DataSet it belongs to. INFORMATION: This method does calculations at
   * runtime. Do not over-use in performance critical situations.
   *
   * @param index
   * @return
   */
  protected getHighlightsAtIndex(index: number): Highlight[] {
    if (this.mChart == null || this.mChart.getData() == null) {
      return [];
    }
    const highlightBuffer: Highlight[] = [];

    let animator = this.mChart.getAnimator();
    if (!animator) {
      return [];
    }
    const phaseX = animator.getPhaseX();
    const phaseY = animator.getPhaseY();
    const sliceangle = this.mChart.getSliceAngle();
    const factor = this.mChart.getFactor();

    let pOut = MPPointF.getInstance(0, 0);

    for (let i = 0; i < this.mChart!.getData()!.getDataSetCount(); i++) {
      const dataSet: IDataSet<EntryOhos> | null = this.mChart!.getData()!.getDataSetByIndex(i);
      if (!dataSet) {
        continue;
      }
      const entry = dataSet.getEntryForIndex(index);

      const y = entry.getY() - this.mChart.getYChartMin();

      let centerOffsets = this.mChart.getCenterOffsets();
      if (this.mChart != null && centerOffsets != null) {
        pOut = Utils.getPosition(
          centerOffsets,
          y * factor * phaseY,
          sliceangle * index * phaseX + this.mChart.getRotationAngle(),
          pOut
        );
      }

      highlightBuffer.push(
        new Highlight(index, entry.getY(), i, 0, 0, pOut.x, pOut.y, dataSet.getAxisDependency())
      );
    }

    return highlightBuffer;
  }
}