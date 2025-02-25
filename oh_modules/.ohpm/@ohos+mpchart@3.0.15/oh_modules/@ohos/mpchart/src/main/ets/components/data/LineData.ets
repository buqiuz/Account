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

import ILineDataSet from '../interfaces/datasets/ILineDataSet';
import { JArrayList } from '../utils/JArrayList';
import BarLineScatterCandleBubbleData from './BarLineScatterCandleBubbleData';

/**
 * Data object that encapsulates all data associated with a LineChart.
 *
 */
export default class LineData extends BarLineScatterCandleBubbleData<ILineDataSet> {
  public constructor();

  public constructor(dataSets: ILineDataSet[]);

  public constructor(dataSets: JArrayList<ILineDataSet>);

  public constructor(dataSets ?: JArrayList<ILineDataSet> | ILineDataSet[]) {
    if (dataSets) {
      if (dataSets instanceof JArrayList) {
        super(dataSets as JArrayList<ILineDataSet>);
      } else {
        super(dataSets as ILineDataSet[]);
      }
    } else {
      super();
    }
  }
}
