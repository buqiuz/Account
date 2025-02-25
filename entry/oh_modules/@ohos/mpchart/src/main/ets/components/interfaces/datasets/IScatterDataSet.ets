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
import ILineScatterCandleRadarDataSet from './ILineScatterCandleRadarDataSet';
import IShapeRenderer from '../../renderer/scatter/IShapeRenderer';

export default interface IScatterDataSet extends ILineScatterCandleRadarDataSet<EntryOhos> {

  /**
   * Returns the currently set scatter shape size
   *
   * @return
   */
  getScatterShapeSize(): number;

  /**
   * Returns radius of the hole in the shape
   *
   * @return
   */
  getScatterShapeHoleRadius(): number;

  /**
   * Returns the color for the hole in the shape
   *
   * @return
   */
  getScatterShapeHoleColor(): number;

  /**
   * Returns the IShapeRenderer responsible for rendering this DataSet.
   *
   * @return
   */
  getShapeRenderer(): IShapeRenderer;
}
