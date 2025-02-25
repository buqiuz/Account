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

import Paint, { Style } from '../../data/Paint';
import IScatterDataSet from '../../interfaces/datasets/IScatterDataSet';
import Utils from '../../utils/Utils';
import ViewPortHandler from '../../utils/ViewPortHandler';
import IShapeRenderer from './IShapeRenderer';


export default class ChevronUpShapeRenderer implements IShapeRenderer {
  public renderShape(c: CanvasRenderingContext2D, dataSet: IScatterDataSet, viewPortHandler: ViewPortHandler,
                     posX: number, posY: number, renderPaint: Paint): void {

    const shapeHalf: number = dataSet.getScatterShapeSize() / 2;

    renderPaint.setStyle(Style.STROKE);
    renderPaint.setStrokeWidth(Utils.handleDataValues(1));


    Utils.resetContext2DWithoutFont(c, renderPaint);
    c.beginPath();
    c.moveTo(posX, posY - (2 * shapeHalf));
    c.lineTo(posX + (2 * shapeHalf), posY);

    c.moveTo(posX, posY - (2 * shapeHalf));
    c.lineTo(posX - (2 * shapeHalf), posY);
    c.stroke();
    c.closePath();


  }
}
