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

import IBarLineScatterCandleBubbleDataSet from '../interfaces/datasets/IBarLineScatterCandleBubbleDataSet';
import { JArrayList } from '../utils/JArrayList';
import ChartData from './ChartData';
import EntryOhos from './EntryOhos';

/**
 * Baseclass for all Line, Bar, Scatter, Candle and Bubble data.
 *
 */
export default abstract class BarLineScatterCandleBubbleData<T extends IBarLineScatterCandleBubbleDataSet< /*T extends */
EntryOhos>>
extends ChartData<T> {
  constructor();

  constructor(sets: T[]);

  constructor(sets: JArrayList<T>);

  constructor(sets ?: JArrayList<T> | T[]) {
    if (sets) {
      if (sets instanceof JArrayList) {
        super(sets as JArrayList<T>)
      } else {
        super(sets as T[]);
      }
    } else {
      super();
    }
  }
}

