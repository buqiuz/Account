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
import EntryOhos from '../data/EntryOhos';

/**
 * Listener for callbacks when selecting values inside the chart by
 * touch-gesture.
 *
 *
 */
export default interface OnChartValueSelectedListener {

  /**
   * Called when a value has been selected inside the chart.
   *
   * @param e The selected Entry
   * @param h The corresponding highlight object that contains information
   *          about the highlighted position such as dataSetIndex, ...
   */
  onValueSelected: (e: EntryOhos, h: Highlight) => void;

  /**
   * Called when nothing has been selected or an "un-select" has been made.
   */
  onNothingSelected: () => void;
}
