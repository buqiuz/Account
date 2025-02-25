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

import IBubbleDataSet from '../interfaces/datasets/IBubbleDataSet';
import { JArrayList } from '../utils/JArrayList';
import BarLineScatterCandleBubbleData from './BarLineScatterCandleBubbleData';

export default class BubbleData extends BarLineScatterCandleBubbleData<IBubbleDataSet> {
  constructor(sets ?: JArrayList<IBubbleDataSet>) {
    super(sets as JArrayList<IBubbleDataSet>);
  }

  /**
   * Sets the width of the circle that surrounds the bubble when highlighted
   * for all DataSet objects this data object contains, in vp.
   *
   * @param width
   */
  public setHighlightCircleWidth(width: number): void {
    if (this.mDataSets) {
      let dataSource = this.mDataSets.dataSource;

      for (let sets of dataSource) {
        sets.setHighlightCircleWidth(width);
      }
    }
  }
}
