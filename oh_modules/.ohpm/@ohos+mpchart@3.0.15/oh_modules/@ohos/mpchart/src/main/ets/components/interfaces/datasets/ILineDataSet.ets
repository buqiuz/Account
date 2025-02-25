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

import EntryOhos from '../../data/EntryOhos';
import { Mode } from '../../data/LineDataSet';
import IFillFormatter from '../../formatter/IFillFormatter';
import ILineRadarDataSet from './ILineRadarDataSet';
import { DashPathEffect } from '../../data/Paint';

export default interface ILineDataSet extends ILineRadarDataSet<EntryOhos> {
  /**
   * Returns the drawing mode for this line dataset
   *
   * @return
   */
  getMode(): Mode;

  /**
   * Returns the intensity of the cubic lines (the effect intensity).
   * Max = 1f = very cubic, Min = 0.05f = low cubic effect, Default: 0.2f
   *
   * @return
   */
  getCubicIntensity(): number;

  /**
   * Returns the size of the drawn circles.
   */
  getCircleRadius(): number;

  /**
   * Returns the hole radius of the drawn circles.
   */
  getCircleHoleRadius(): number;

  /**
   * Returns the color at the given index of the DataSet's circle-color array.
   * Performs a IndexOutOfBounds check by modulus.
   *
   * @param index
   * @return
   */
  getCircleColorByIndex(index: number): number;

  getCircleColor(index: number): number;

  /**
   * Returns the number of colors in this DataSet's circle-color array.
   *
   * @return
   */
  getCircleColorCount(): number;

  /**
   * Returns true if drawing circles for this DataSet is enabled, false if not
   *
   * @return
   */
  isDrawCirclesEnabled(): boolean;

  /**
   * Returns the color of the inner circle (the circle-hole).
   *
   * @return
   */
  getCircleHoleColor(): number;

  /**
   * Returns true if drawing the circle-holes is enabled, false if not.
   *
   * @return
   */
  isDrawCircleHoleEnabled(): boolean;

  isDrawSteppedEnabled(): boolean;

  /**
   * Returns the DashPathEffect that is used for drawing the lines.
   *
   * @return
   */
  getDashPathEffect(): DashPathEffect | null;

  /**
   * Returns true if the dashed-line effect is enabled, false if not.
   * If the DashPathEffect object is null, also return false here.
   *
   * @return
   */
  isDashedLineEnabled(): boolean;

  /**
   * Returns the IFillFormatter that is set for this DataSet.
   *
   * @return
   */
  getFillFormatter(): IFillFormatter;

  // getFillStyle(): FillStyle | null;
}