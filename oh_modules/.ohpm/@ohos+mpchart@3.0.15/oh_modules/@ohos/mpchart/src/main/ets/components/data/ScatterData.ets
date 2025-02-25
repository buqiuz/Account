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

import IScatterDataSet from '../interfaces/datasets/IScatterDataSet';
import { JArrayList } from '../utils/JArrayList';
import BarLineScatterCandleBubbleData from './BarLineScatterCandleBubbleData';

export class ScatterData extends BarLineScatterCandleBubbleData<IScatterDataSet> {
  constructor(dataSets?: JArrayList<IScatterDataSet>) {
    super(dataSets as JArrayList<IScatterDataSet>);
  }

  /**
   * Returns the maximum shape-size across all DataSets.
   *
   * @return
   */
  public getGreatestShapeSize() {

    let max = 0;
    for (let i = 0;i < this.mDataSets.size(); i++) {
      const set = this.mDataSets.get(i);
      const size = set.getScatterShapeSize();

      if (size > max)
        max = size;
    }

    return max;
  }
}