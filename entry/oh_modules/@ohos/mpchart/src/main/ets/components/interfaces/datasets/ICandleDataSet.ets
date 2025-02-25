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

import ILineScatterCandleRadarDataSet from './ILineScatterCandleRadarDataSet';
import { Style } from '../../data/Paint';
import CandleEntry from '../../data/CandleEntry';

export default interface ICandleDataSet extends ILineScatterCandleRadarDataSet<CandleEntry> {

  /**
   * Returns the space that is left out on the left and right side of each
   * candle.
   *
   * @return
   */
  getBarSpace(): number;

  /**
   * Returns whether the candle bars should show?
   * When false, only "ticks" will show
   *
   * - default: true
   *
   * @return
   */
  getShowCandleBar(): boolean;

  /**
   * Returns the width of the candle-shadow-line in pixels.
   *
   * @return
   */
  getShadowWidth(): number;

  /**
   * Returns shadow color for all entries
   *
   * @return
   */
  getShadowColor(): number;

  /**
   * Returns the neutral color (for open == close)
   *
   * @return
   */
  getNeutralColor(): number;

  /**
   * Returns the increasing color (for open < close).
   *
   * @return
   */
  getIncreasingColor(): number;

  /**
   * Returns the decreasing color (for open > close).
   *
   * @return
   */
  getDecreasingColor(): number;

  /**
   * Returns paint style when open < close
   *
   * @return
   */
  getIncreasingPaintStyle(): Style;

  /**
   * Returns paint style when open > close
   *
   * @return
   */
  getDecreasingPaintStyle(): Style;

  /**
   * Is the shadow color same as the candle color?
   *
   * @return
   */
  getShadowColorSameAsCandle(): boolean;
}
