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

import PieEntry from '../../data/PieEntry';
import IDataSet from './IDataSet';
import { ValuePosition } from '../../data/PieDataSet';

export default interface IPieDataSet extends IDataSet<PieEntry> {

  /**
   * Returns the space that is set to be between the piechart-slices of this
   * DataSet, in pixels.
   *
   * @return
   */
  getSliceSpace(): number;

  /**
   * When enabled, slice spacing will be 0.0 when the smallest value is going to be
   *   smaller than the slice spacing itself.
   *
   * @return
   */
  isAutomaticallyDisableSliceSpacingEnabled(): boolean;

  /**
   * Returns the distance a highlighted piechart slice is "shifted" away from
   * the chart-center in vp.
   *
   * @return
   */
  getSelectionShift(): number;

  getXValuePosition(): ValuePosition;

  getYValuePosition(): ValuePosition;

  /**
   * When valuePosition is OutsideSlice, indicates line color
   * */
  getValueLineColor(): number;

  /**
   * When valuePosition is OutsideSlice and enabled, line will have the same color as the slice
   * */
  isUseValueColorForLineEnabled(): boolean;

  /**
   *  When valuePosition is OutsideSlice, indicates line width
   *  */
  getValueLineWidth(): number;

  /**
   * When valuePosition is OutsideSlice, indicates offset as percentage out of the slice size
   * */
  getValueLinePart1OffsetPercentage(): number;

  /**
   * When valuePosition is OutsideSlice, indicates length of first half of the line
   * */
  getValueLinePart1Length(): number;

  /**
   * When valuePosition is OutsideSlice, indicates length of second half of the line
   * */
  getValueLinePart2Length(): number;

  /**
   * When valuePosition is OutsideSlice, this allows variable line length
   * */
  isValueLineVariableLength(): boolean;

  /**
   * Gets the color for the highlighted sector
   * */
  // @Nullable
  getHighlightColor(): number | null;

}

