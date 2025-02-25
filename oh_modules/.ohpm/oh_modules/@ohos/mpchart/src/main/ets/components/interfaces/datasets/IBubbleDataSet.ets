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

import BubbleEntry from '../../data/BubbleEntry';
import IBarLineScatterCandleBubbleDataSet from './IBarLineScatterCandleBubbleDataSet';

export default interface IBubbleDataSet extends IBarLineScatterCandleBubbleDataSet<BubbleEntry> {

  /**
   * Sets the width of the circle that surrounds the bubble when highlighted,
   * in vp.
   *
   * @param width
   */
  setHighlightCircleWidth(width: number): void;

  getMaxSize(): number;

  isNormalizeSizeEnabled(): boolean;

  /**
   * Returns the width of the highlight-circle that surrounds the bubble
   * @return
   */
  getHighlightCircleWidth(): number;
}
