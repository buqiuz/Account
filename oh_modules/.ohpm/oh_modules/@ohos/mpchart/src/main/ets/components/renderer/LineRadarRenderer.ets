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

import ChartAnimator from '../animation/ChartAnimator';
import ChartPixelMap from '../data/ChartPixelMap';
import { ChartColorStop } from '../data/LineDataSet';
import { JArrayList } from '../utils/JArrayList';
import Utils from '../utils/Utils';
import ViewPortHandler from '../utils/ViewPortHandler';
import LineScatterCandleRadarRenderer from './LineScatterCandleRadarRenderer';

export abstract class LineRadarRenderer extends LineScatterCandleRadarRenderer {
  constructor(animator: ChartAnimator, viewPortHandler: ViewPortHandler) {
    super(animator, viewPortHandler);
  }

  /**
   * Draws the provided path in filled mode with the provided color and alpha.
   * Special thanks to Angelo Suzuki (https://github.com/tinsukE) for this.
   *
   * @param c
   * @param filledPath
   * @param fillColor
   * @param fillAlpha
   */
  protected drawFilledPathWithAlpha(c: CanvasRenderingContext2D, filledPath: Path2D, fillColor: number | string, fillAlpha: number) {
    let color: number = 0;

    // 如果传入的颜色是字符串形式
    if (typeof (fillColor) == "string" && fillColor.startsWith("#")) {
      // 将字符串颜色值转换为数字格式
      color = Number.parseInt(fillColor.substr(1), 16);
    } else {
      color = Number(fillColor);
    }

    if(fillAlpha > 255){
      fillAlpha = 255;
    }
    if(fillAlpha < 0){
      fillAlpha = 0;
    }

    // 使用修改后的颜色值进行绘制
    c.fillStyle = `rgba(${(color >> 16) & 0xff}, ${(color >> 8) & 0xff}, ${color & 0xff}, ${fillAlpha / 255})`;
    c.fill(filledPath);
  }

  /**
   * Draws the provided path in filled mode with the provided drawable.
   *
   * @param c
   * @param filledPath
   * @param drawable
   */
  protected drawFilledPath(c: CanvasRenderingContext2D, filledPath: Path2D, drawable: ChartPixelMap) {

    if (this.clipPathSupported()) {

      c.save();
      c.clip(filledPath);

      // drawable.setBounds(
      //   Math.floor(this.mViewPortHandler.contentLeft()),
      //   Math.floor(this.mViewPortHandler.contentTop()),
      //   Math.floor(this.mViewPortHandler.contentRight()),
      //   Math.floor(this.mViewPortHandler.contentBottom())
      // );
      // drawable.draw(c);
      //
      // c.restoreToCount(save);
      if (this.mViewPortHandler) {
        c.rect(this.mViewPortHandler.contentLeft(),
          this.mViewPortHandler.contentTop(),
          this.mViewPortHandler.contentRight() - this.mViewPortHandler.contentLeft(),
          this.mViewPortHandler.contentBottom() - this.mViewPortHandler.contentTop()
        );
      }
      c.restore();

    } else {
      throw new Error("Fill-drawables not (yet) supported below API level 18, " +
      "this code was run on API level " + Utils.getSDKInt() + ".");
    }
  }

  /**
   * Clip path with hardware acceleration only working properly on API level 18 and above.
   *
   * @return
   */
  private clipPathSupported(): boolean {
    return Utils.getSDKInt() >= 8;
  }

  protected drawGradientFill(c: CanvasRenderingContext2D, filledPath: Path2D, gradientColor: JArrayList<ChartColorStop>, topValue: number, bottomValue: number) {
    let gradient = c.createLinearGradient(0, topValue, 0, bottomValue);
    for (let i = 0; i < gradientColor.size(); i++) {
      let colorStop: ChartColorStop = gradientColor.get(i);
      if (colorStop) {
        gradient.addColorStop(colorStop[1], colorStop[0]);
      }
    }
    c.fillStyle = gradient;
    c.fill(filledPath);
  }
}
