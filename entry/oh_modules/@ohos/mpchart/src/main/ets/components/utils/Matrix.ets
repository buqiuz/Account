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

import MyRect from '../data/Rect';

/**
 * 仅用于translate 和 scale，rotate、skew未移植
 */
export default class Matrix {
  public static MSCALE_X: number = 0;
  //!< use with getValues/setValues
  public static MSKEW_X: number = 1;
  //!< use with getValues/setValues
  public static MTRANS_X: number = 2;
  //!< use with getValues/setValues
  public static MSKEW_Y: number = 3;
  //!< use with getValues/setValues
  public static MSCALE_Y: number = 4;
  //!< use with getValues/setValues
  public static MTRANS_Y: number = 5;
  //!< use with getValues/setValues
  public static MPERSP_0: number = 6;
  //!< use with getValues/setValues
  public static MPERSP_1: number = 7;
  //!< use with getValues/setValues
  public static MPERSP_2: number = 8;
  //!< use with getValues/setValues

  private data: number[] = [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0];

  public reset() {
    this.data = [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0];
  }

  public set(matrix: Matrix) {
    this.data[Matrix.MSCALE_X] = matrix.getValues()[Matrix.MSCALE_X]
    this.data[Matrix.MSKEW_X] = matrix.getValues()[Matrix.MSKEW_X]
    this.data[Matrix.MTRANS_X] = matrix.getValues()[Matrix.MTRANS_X]
    this.data[Matrix.MSKEW_Y] = matrix.getValues()[Matrix.MSKEW_Y]
    this.data[Matrix.MSCALE_Y] = matrix.getValues()[Matrix.MSCALE_Y]
    this.data[Matrix.MTRANS_Y] = matrix.getValues()[Matrix.MTRANS_Y]
    this.data[Matrix.MPERSP_0] = matrix.getValues()[Matrix.MPERSP_0]
    this.data[Matrix.MPERSP_1] = matrix.getValues()[Matrix.MPERSP_1]
    this.data[Matrix.MPERSP_2] = matrix.getValues()[Matrix.MPERSP_2]
  }

  public getValues(): number[] {
    return this.data;
  }

  public setValues(values: number[]) {
    this.data = values;
  }

  /**
   * 在矩阵上应用缩放变换。
   * @param scaleX - 水平方向的缩放因子。
   * @param scaleY - 垂直方向的缩放因子。
   * @param centerX - 可选参数，缩放的中心点的X坐标。
   * @param centerY - 可选参数，缩放的中心点的Y坐标。
   */
  public postScale(scaleX: number, scaleY: number, centerX?: number, centerY?: number) {
    // 缩放矩阵的水平和垂直缩放因子
    this.data[Matrix.MSCALE_X] *= scaleX;
    this.data[Matrix.MSCALE_Y] *= scaleY;

    // 如果提供了中心点的X坐标，则按照中心点缩放
    if (centerX != null && centerX != undefined) {
      this.data[Matrix.MTRANS_X] = scaleX * (this.data[Matrix.MTRANS_X] - centerX) + centerX;
    } else {
      // 否则，只在X方向上应用缩放
      this.data[Matrix.MTRANS_X] *= scaleX;
    }

    // 如果提供了中心点的Y坐标，则按照中心点缩放
    if (centerY != null && centerY != undefined) {
      this.data[Matrix.MTRANS_Y] = scaleY * (this.data[Matrix.MTRANS_Y] - centerY) + centerY;
    } else {
      // 否则，只在Y方向上应用缩放
      this.data[Matrix.MTRANS_Y] *= scaleY;
    }
  }


  public setScale(scaleX: number, scaleY: number, centerX?: number, centerY?: number) {
    this.data[Matrix.MSCALE_X] = scaleX;
    this.data[Matrix.MSCALE_Y] = scaleY;
    if (centerX != null && centerX != undefined) {
      this.data[Matrix.MTRANS_X] += -centerX * scaleX;
    } else {
      this.data[Matrix.MTRANS_X] = 0
    }
    if (centerY != null && centerY != undefined) {
      this.data[Matrix.MTRANS_Y] += -centerY * scaleY;
    } else {
      this.data[Matrix.MTRANS_Y] = 0
    }
  }

  public postTranslate(dx: number, dy: number) {
    if (!Number.isNaN(dx) && dx != undefined) {
      this.data[Matrix.MTRANS_X] += dx;
    }
    if (!Number.isNaN(dy) && dy != undefined) {
      this.data[Matrix.MTRANS_Y] += dy;
    }
  }

  public setTranslate(dx: number, dy: number) {
    if (!Number.isNaN(dx) && dx != undefined) {
      this.data[Matrix.MTRANS_X] = dx;
    }
    if (!Number.isNaN(dy) && dy != undefined) {
      this.data[Matrix.MTRANS_Y] = dy;
    }
    this.data[Matrix.MSCALE_X] = 1
    this.data[Matrix.MSCALE_Y] = 1
  }

  public postConcat(matrix: Matrix) {
    let values = matrix.getValues();
    this.postScale(values[Matrix.MSCALE_X], values[Matrix.MSCALE_Y]);
    this.postTranslate(values[Matrix.MTRANS_X], values[Matrix.MTRANS_Y]);
    //    this.data[Matrix.MTRANS_X] = values[Matrix.MTRANS_X] * this.data[Matrix.MSCALE_X]
    //    this.data[Matrix.MSCALE_X] *= values[Matrix.MSCALE_X]
    //    this.data[Matrix.MSCALE_Y] *= values[Matrix.MSCALE_Y]
  }

  public mapPoints(pts: number[]) {
    const len = pts.length;
    const scale_x = this.data[Matrix.MSCALE_X];
    const scale_y = this.data[Matrix.MSCALE_Y];
    const trans_x = this.data[Matrix.MTRANS_X];
    const trans_y = this.data[Matrix.MTRANS_Y];
    for (let i = 0; i < len; i += 2) {
      pts[i] = pts[i] * scale_x + trans_x;
    }
    for (let i = 1; i < len; i += 2) {
      pts[i] = pts[i] * scale_y + trans_y;
    }
  }

  public mapRect(rect: MyRect) {
    // let x: number = this.data[Matrix.MTRANS_X];
    // let y: number = this.data[Matrix.MTRANS_Y];
    // rect.set(rect.left + x, rect.top + y, rect.right + x, rect.bottom + y);

    let translate_x: number = this.data[Matrix.MTRANS_X];
    let translate_y: number = this.data[Matrix.MTRANS_Y];
    let scale_x: number = this.data[Matrix.MSCALE_X];
    let scale_y: number = this.data[Matrix.MSCALE_Y];

    let yValue1: number = rect.top * scale_y + translate_y;
    let yValue2: number = rect.bottom * scale_y + translate_y;
    if (yValue1 < yValue2) {
      rect.set(rect.left * scale_x + translate_x, yValue1, rect.right * scale_x + translate_x, yValue2);
    } else {
      rect.set(rect.left * scale_x + translate_x, yValue2, rect.right * scale_x + translate_x, yValue1);
    }
  }

  public invert(matrix: Matrix) {
    let values: number[] = matrix.getValues();
    values[Matrix.MSCALE_X] = 1 / (this.data[Matrix.MSCALE_X] / 1)
    values[Matrix.MSCALE_Y] = 1 / (this.data[Matrix.MSCALE_Y] / 1)
    values[Matrix.MTRANS_X] = -this.data[Matrix.MTRANS_X] * values[Matrix.MSCALE_X]
    values[Matrix.MTRANS_Y] = -this.data[Matrix.MTRANS_Y] * values[Matrix.MSCALE_Y]
    matrix.setValues(values);
    return matrix;
  }

  private checkValue() {
    for (let i = 0; i < this.data.length; i++) {
      if (Number.isNaN(this.data[i]) || this.data[i] == undefined) {
        if (i == Matrix.MSCALE_X || i == Matrix.MSCALE_Y || i == Matrix.MPERSP_2) {
          this.data[i] = 1
        } else {
          this.data[i] = 0
        }
      }
    }
  }
}