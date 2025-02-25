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
export default class CircleShapeRenderer implements IShapeRenderer {
  public renderShape(c: CanvasRenderingContext2D, dataSet: IScatterDataSet, viewPortHandler: ViewPortHandler,
                     posX: number, posY: number, renderPaint: Paint): void {

    const shapeSize: number = dataSet.getScatterShapeSize();
    const shapeHalf: number = shapeSize / 2;
    const shapeHoleSizeHalf: number = Utils.handleDataValues(dataSet.getScatterShapeHoleRadius());
    const shapeHoleSize: number = shapeHoleSizeHalf * 2;
    const shapeStrokeSize: number = (shapeSize - shapeHoleSize) / 2;
    const shapeStrokeSizeHalf: number = shapeStrokeSize / 2;

    const shapeHoleColor: number = dataSet.getScatterShapeHoleColor();

    if (shapeSize > 0.0) {
      renderPaint.setStyle(Style.STROKE);
      renderPaint.setStrokeWidth(shapeStrokeSize);

      Utils.resetContext2DWithoutFont(c, renderPaint);
      c.beginPath();
      let path: Path2D = new Path2D();
      path.arc(posX, posY, shapeHoleSizeHalf + shapeStrokeSizeHalf, 0, 2 * Math.PI);
      c.stroke(path);
      c.closePath();

      if (shapeHoleColor != ColorTemplate.COLOR_NONE) {
        renderPaint.setStyle(Style.FILL);

        renderPaint.setColor(shapeHoleColor);

        Utils.resetContext2DWithoutFont(c, renderPaint);
        c.beginPath();
        let path: Path2D = new Path2D();
        path.arc(posX, posY, shapeHoleSizeHalf, 0, 2 * Math.PI);
        c.fill(path);
        c.closePath();
      }
    } else {
      renderPaint.setStyle(Style.FILL);

      Utils.resetContext2DWithoutFont(c, renderPaint);
      c.beginPath();
      c.arc(posX, posY, shapeHalf, 0, 2 * Math.PI);
      c.stroke();
      c.closePath();
    }

  }
}
