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

import BarLineScatterCandleBubbleData from './BarLineScatterCandleBubbleData';
import ICandleDataSet from '../interfaces/datasets/ICandleDataSet';
import { JArrayList } from '../utils/JArrayList';

export default class CandleData extends BarLineScatterCandleBubbleData<ICandleDataSet> {
  constructor();

  constructor(dataSets: JArrayList<ICandleDataSet>);

  constructor(dataSets: ICandleDataSet[]);

  constructor(dataSets?: JArrayList<ICandleDataSet> | ICandleDataSet[]) {
    if (!dataSets) {
      super();
    } else {
      if (dataSets instanceof JArrayList) {
        super(dataSets as JArrayList<ICandleDataSet>)
      } else {
        super(dataSets as ICandleDataSet[])
      }
    }
  }
}
