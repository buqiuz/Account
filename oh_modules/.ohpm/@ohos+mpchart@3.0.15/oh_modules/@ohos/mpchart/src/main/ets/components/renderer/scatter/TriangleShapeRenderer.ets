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
import ColorTemplate from '../../utils/ColorTemplate';
import Utils from '../../utils/Utils';
import ViewPortHandler from '../../utils/ViewPortHandler';
import IShapeRenderer from './IShapeRenderer';


/**
 * Created by wajdic on 15/06/2016.
 * Created at Time 09:08
 */
export default class TriangleShapeRenderer implements IShapeRenderer {
  //不确定改为Path2D还是Path
  protected mTrianglePathBuffer: Path2D = new Path2D();

  public renderShape(c: CanvasRenderingContext2D, dataSet: IScatterDataSet, viewPortHandler: ViewPortHandler,
                     posX: number, posY: number, renderPaint: Paint): void {

    const shapeSize: number = dataSet.getScatterShapeSize();
    const shapeHalf: number = shapeSize / 2;
    const shapeHoleSizeHalf: number = Utils.handleDataValues(dataSet.getScatterShapeHoleRadius());
    const shapeHoleSize: number = shapeHoleSizeHalf * 2;
    const shapeStrokeSize: number = (shapeSize - shapeHoleSize) / 2;

    const shapeHoleColor: number = dataSet.getScatterShapeHoleColor();

    renderPaint.setStyle(Style.FILL);

    // create a triangle path
    // Path tri = mTrianglePathBuffer;
    let tri: Path2D = this.mTrianglePathBuffer
    // tri.reset();
    tri = new Path2D();

    tri.moveTo(posX, posY - shapeHalf);
    tri.lineTo(posX + shapeHalf, posY + shapeHalf);
    tri.lineTo(posX - shapeHalf, posY + shapeHalf);

    if (shapeSize > 0.0) {
      tri.lineTo(posX, posY - shapeHalf);

      tri.moveTo(posX - shapeHalf + shapeStrokeSize, posY + shapeHalf - shapeStrokeSize);
      tri.lineTo(posX + shapeHalf - shapeStrokeSize, posY + shapeHalf - shapeStrokeSize);
      tri.lineTo(posX, posY - shapeHalf + shapeStrokeSize);
      tri.lineTo(posX - shapeHalf + shapeStrokeSize, posY + shapeHalf - shapeStrokeSize);
    }

    tri.closePath();
    Utils.resetContext2DWithoutFont(c, renderPaint)
    c.beginPath()
    c.stroke(tri);
    c.closePath();
    // tri.reset();
    // tri = new Path2D();
    if (shapeSize > 0.0 && shapeHoleColor != ColorTemplate.COLOR_NONE) {

      renderPaint.setColor(shapeHoleColor);

      tri.moveTo(posX, posY - shapeHalf + shapeStrokeSize);
      tri.lineTo(posX + shapeHalf - shapeStrokeSize, posY + shapeHalf - shapeStrokeSize);
      tri.lineTo(posX - shapeHalf + shapeStrokeSize, posY + shapeHalf - shapeStrokeSize);
      tri.closePath();

      // c.drawPath(tri, renderPaint);
      Utils.resetContext2DWithoutFont(c, renderPaint)
      c.beginPath()
      c.stroke(tri);
      c.closePath();

      // tri.reset();
      // tri = new Path2D();
    }

  }
}