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

import Transformer from './Transformer';
import ViewPortHandler from './ViewPortHandler';

export default class TransformerHorizontalBarChart extends Transformer {
  constructor(viewPortHandler: ViewPortHandler) {
    super(viewPortHandler);
  }

  /**
   * Prepares the matrix that contains all offsets.
   *
   * @param inverted
   */
  public prepareMatrixOffset(inverted: boolean): void {

    this.mMatrixOffset.reset();

    // offset.postTranslate(mOffsetLeft, getHeight() - mOffsetBottom);

    if (!inverted)
      this.mMatrixOffset.postTranslate(this.mViewPortHandler.offsetLeft(),
        this.mViewPortHandler.getChartHeight() - this.mViewPortHandler.offsetBottom());
    else {
      this.mMatrixOffset
        .setTranslate(
          -(this.mViewPortHandler.getChartWidth() - this.mViewPortHandler.offsetRight()),
          this.mViewPortHandler.getChartHeight() - this.mViewPortHandler.offsetBottom());
      this.mMatrixOffset.postScale(-1.0, 1.0);
    }
    // mMatrixOffset.set(offset);

    // mMatrixOffset.reset();
    //
    // mMatrixOffset.postTranslate(mOffsetLeft, getHeight() -
    // mOffsetBottom);
  }
}