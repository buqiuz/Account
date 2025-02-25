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

import BarEntry from '../../data/BarEntry';

import Fill from '../../utils/Fill';
import { JArrayList } from '../../utils/JArrayList';
import IBarLineScatterCandleBubbleDataSet from './IBarLineScatterCandleBubbleDataSet';

export default interface IBarDataSet extends IBarLineScatterCandleBubbleDataSet<BarEntry> {

  getFills(): JArrayList<Fill> | null;

  getFill(index: number): Fill | null;

  /**
   * Returns true if this DataSet is stacked (stacksize > 1) or not.
   *
   * @return
   */
  isStacked(): boolean;

  /**
   * Returns the maximum number of bars that can be stacked upon another in
   * this DataSet. This should return 1 for non stacked bars, and > 1 for stacked bars.
   *
   * @return
   */
  getStackSize(): number;

  /**
   * Returns the color used for drawing the bar-shadows. The bar shadows is a
   * surface behind the bar that indicates the maximum value.
   *
   * @return
   */
  getBarShadowColor(): number;

  /**
   * Returns the width used for drawing borders around the bars.
   * If borderWidth == 0, no border will be drawn.
   *
   * @return
   */
  getBarBorderWidth(): number;

  /**
   * Returns the color drawing borders around the bars.
   *
   * @return
   */
  getBarBorderColor(): number;

  /**
   * Returns the alpha value (transparency) that is used for drawing the
   * highlight indicator.
   *
   * @return
   */
  getHighLightAlpha(): number;

  /**
   * Returns the labels used for the different value-stacks in the legend.
   * This is only relevant for stacked bar entries.
   *
   * @return
   */
  getStackLabels(): string[];
}
