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
import IRadarDataSet from '../interfaces/datasets/IRadarDataSet';
import { JArrayList } from '../utils/JArrayList';
import ChartData from './ChartData';
import EntryOhos from './EntryOhos';

export default class RadarData extends ChartData<IRadarDataSet> {
  private mLabels: string[] | undefined;

  constructor(dataSets?: IRadarDataSet[] | JArrayList<IRadarDataSet>) {

    if (dataSets) {
      if (dataSets instanceof JArrayList) {
        super(dataSets);
      } else {
        super(dataSets);
      }
    } else {
      super();
    }
  }

  /**
   * Sets the labels that should be drawn around the RadarChart at the end of each web line.
   *
   * @param labels
   */
  setLabels(labels: string[]): void;

  /**
   * Sets the labels that should be drawn around the RadarChart at the end of each web line.
   *
   * @param labels
   */
  setLabels(labels: string[] | string): void {
    this.mLabels = Array.isArray(labels) ? labels : [labels];
  }

  getLabels(): string[] | undefined {
    return this.mLabels;
  }

  getEntryForHighlight(highlight: Highlight): EntryOhos | null {
    const dataSet = this.getDataSetByIndex(highlight.getDataSetIndex());
    return dataSet ? dataSet.getEntryForIndex(Math.floor(highlight.getX())) : null;
  }
}