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

import Paint from '../../data/Paint';
import IScatterDataSet from '../../interfaces/datasets/IScatterDataSet';
import ViewPortHandler from '../../utils/ViewPortHandler';

export default interface IShapeRenderer {
  /**
   * Renders the provided ScatterDataSet with a shape.
   *
   * @param c               Canvas object for drawing the shape
   * @param dataSet         The DataSet to be drawn
   * @param viewPortHandler Contains information about the current state of the view
   * @param posX            Position to draw the shape at
   * @param posY            Position to draw the shape at
   * @param renderPaint     Paint object used for styling and drawing
   */
  renderShape(context2d: CanvasRenderingContext2D, dataSet: IScatterDataSet, viewPortHandler: ViewPortHandler,
              posX: number, posY: number, renderPaint: Paint): void;
}
