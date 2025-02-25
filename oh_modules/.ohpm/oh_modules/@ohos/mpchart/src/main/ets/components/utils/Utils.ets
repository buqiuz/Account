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

import Paint, { Style } from '../data/Paint'
import MyRect from '../data/Rect'
import FSize from './FSize'
import MPPointF from './MPPointF'
import IValueFormatter from '../formatter/IValueFormatter'
import DefaultValueFormatter from '../formatter/DefaultValueFormatter'
import deviceInfo from '@ohos.deviceInfo'
import ChartPixelMap from '../data/ChartPixelMap'
import Highlight from '../highlight/Highlight'
import { XAxisLabelPosition } from '../components/XAxisLabelPosition'
import HashMap from '@ohos.util.HashMap'

/**
 * Utilities class that has some helper methods. Needs to be initialized by
 * calling Utils.init(...) before usage. Inside the Chart.init() method, this is
 * done, if the Utils are used before that, Utils.init(...) needs to be called
 * manually.
 *
 *
 */
export default abstract class Utils {
  private static scaledDensity: number = 3.3125;
  private static mMinimumFlingVelocity: number = 50;
  private static mMaximumFlingVelocity: number = 8000;
  public static DEG2RAD: number = (Math.PI / 180.0);
  public static FDEG2RAD: number = (Math.PI / 180.0);
  public static DOUBLE_EPSILON: number = 4.9E-324;
  public static FLOAT_EPSILON: number = 1.4E-45;
  public static contextSettings: RenderingContextSettings = new RenderingContextSettings(true);
  public static offCanvasContext2d: OffscreenCanvasRenderingContext2D = new OffscreenCanvasRenderingContext2D(500, 500, Utils.contextSettings);
  public static sdkInt: number | undefined = undefined;

  /**
   * initialize method, called inside the Chart.init() method.
   *
   * @param context
   */
  public static init() {
  }

  public static handleDataValues(dp: number): number {
    return dp;
  }

  public static setScaledDensity(value: number) {
    Utils.scaledDensity = value
  }

  public static calcText(paint: Paint, demoText: string): TextMetrics {
    Utils.resetContext2DFont(Utils.offCanvasContext2d, paint);
    let textMetrics: TextMetrics = Utils.offCanvasContext2d.measureText(demoText);
    return textMetrics;
  }

  /**
   * calculates the approximate width of a text, depending on a demo text
   * avoid repeated calls (e.g. inside drawing methods)
   *
   * @param paint
   * @param demoText
   * @return
   */
  public static calcTextWidth(paint: Paint, demoText: string): number {
    Utils.resetContext2DFont(Utils.offCanvasContext2d, paint);
    let textMetrics: TextMetrics = Utils.offCanvasContext2d.measureText(demoText);
    return textMetrics.width;
  }

  private static mCalcTextHeightRect: MyRect = new MyRect();

  /**
   * calculates the approximate height of a text, depending on a demo text
   * avoid repeated calls (e.g. inside drawing methods)
   *
   * @param paint
   * @param demoText
   * @return
   */
  public static calcTextHeight(paint: Paint, demoText: string): number {

    Utils.resetContext2DFont(Utils.offCanvasContext2d, paint);
    let textMetrics: TextMetrics = Utils.offCanvasContext2d.measureText(demoText);
    return textMetrics.height;
  }


  public static getLineHeight(paint: Paint, c?: CanvasRenderer): number {
    if (!c) {
      c = Utils.offCanvasContext2d;
    }
    Utils.resetContext2DFont(c, paint);
    let textMetrics: TextMetrics = c.measureText('Test');
    return textMetrics.height;
  }

  public static getLineSpacing(paint: Paint, c?: CanvasRenderer): number {
    if (!c) {
      c = Utils.offCanvasContext2d;
    }
    Utils.resetContext2DFont(c, paint);
    let textMetrics: TextMetrics = c.measureText('Test');
    //canvas暂未正确实现以下属性，目前属性值为0，等待后续实现
    // return textMetrics.actualBoundingBoxAscent - textMetrics.fontBoundingBoxAscent + textMetrics.fontBoundingBoxDescent;
    return textMetrics.height * 0.3;
  }

  public static calcTextSize(paint: Paint, demoText: string): FSize {
    Utils.resetContext2DFont(Utils.offCanvasContext2d, paint);
    let textMetrics: TextMetrics = Utils.offCanvasContext2d.measureText(demoText);
    let width: number = textMetrics.width;
    let height: number = textMetrics.height;
    let fsize: FSize = new FSize(width, height);
    return fsize;
  }

  public static getLabelTextSize(paint: Paint, text: string, textSizeCache: HashMap<string, TextMetrics>): TextMetrics {
    const font = paint.font;
    const textSizeTemp = textSizeCache.get(text + font);
    if (textSizeTemp) {
      return textSizeTemp;
    } else {
      const textSize = Utils.calcText(paint, text);
      textSizeCache.set(text + font, textSize);
      return textSize;
    }
  }

  public static getLabelTextSizeWithoutPaint(text: string, textSizeCache: HashMap<string, TextMetrics>): TextMetrics {
    const textSizeTemp = textSizeCache.get(text);
    if (textSizeTemp) {
      return textSizeTemp;
    } else {
      let textMetrics: TextMetrics = Utils.offCanvasContext2d.measureText(text);
      textSizeCache.set(text, textMetrics);
      return textMetrics;
    }
  }

  private static mDefaultValueFormatter: IValueFormatter = Utils.generateDefaultValueFormatter();

  private static generateDefaultValueFormatter(): IValueFormatter {
    let formatter: DefaultValueFormatter = new DefaultValueFormatter(1);
    return formatter;
  }

  //    /// - returns: The default value formatter used for all chart components that needs a default
  public static getDefaultValueFormatter(): IValueFormatter {
    return Utils.mDefaultValueFormatter;
  }

  /**
   * rounds the given number to the next significant number
   *
   * @param number
   * @return
   */
  public static roundToNextSignificant(number: number): number {
    if (number == Number.MAX_VALUE ||
    Number.isNaN(number) ||
      number == 0.0)
      return 0;

    const d: number = Math.ceil(Math.log10(number < 0 ? -number : number));
    const pw: number = 1 - Math.floor(d);
    const magnitude: number = Math.pow(10, pw);
    const shifted: number = Math.round(number * magnitude);
    return shifted / magnitude;
  }

  /**
   * Returns the appropriate number of decimals to be used for the provided
   * number.
   *
   * @param number
   * @return
   */
  public static getDecimals(number: number): number {

    let i: number = Utils.roundToNextSignificant(number);

    if (i == Number.MAX_VALUE)
      return 0;

    return Math.floor(Math.ceil(-Math.log10(i)) + 2);
  }

  /**
   * Replacement for the Math.nextUp(...) method that is only available in
   * HONEYCOMB and higher. Dat's some seeeeek sheeet.
   *
   * @param d
   * @return
   */
  public static nextUp(d: number): number {
    if (d == Number.MAX_VALUE)
      return d;
    else {
      d += 0.0;
      return d += 0.000000001;
    }
  }


  /**
   * Returns a recyclable MPPointF instance.
   * Calculates the position around a center point, depending on the distance
   * from the center, and the angle of the position around the center.
   *
   * @param center
   * @param dist
   * @param angle  in degrees, converted to radians internally
   * @return
   */
  public static getPosition(center: MPPointF, dist: number, angle: number, outputPoint?: MPPointF): MPPointF {
    let p: MPPointF = ((outputPoint == null || outputPoint == undefined) ? MPPointF.getInstance(0, 0) : outputPoint);
    p.x = center.x + dist * Math.cos((angle * Math.PI / 180));
    p.y = center.y + dist * Math.sin((angle * Math.PI / 180));
    return p
  }

  public static getMinimumFlingVelocity(): number {
    return Utils.mMinimumFlingVelocity;
  }

  /**
   * returns an angle between 0.f < 360.f (not less than zero, less than 360)
   */
  public static getNormalizedAngle(angle: number): number {
    while (angle < 0)
      angle += 360;

    return angle % 360;
  }

  private static mDrawableBoundsCache: MyRect = new MyRect();

  public static async drawImage(canvas: CanvasRenderingContext2D, drawable: ChartPixelMap,
                          x: number, y: number, width: number, height: number): Promise<void> {

    let pixelMap =await drawable.getIcon();
    if (pixelMap) {
      canvas.drawImage(pixelMap, x-width/2, y-height/2, width , height);
    }
  }

  private static mFontMetricsBuffer: TextMetrics | null = null;

  public static drawXAxisValue(c: CanvasRenderingContext2D, text: string, x: number, y: number,
                               paint: Paint, anchor: MPPointF, angleDegrees: number, labelPosition: XAxisLabelPosition = XAxisLabelPosition.Center, isHorizontalFlip: boolean = false): void {
    let drawOffsetX: number = 0.0;
    let drawOffsetY: number = 0.0;

    // 防止计算出来的宽度，高度等数据不准确
    Utils.resetContext2DFont(c, paint);
    Utils.mFontMetricsBuffer = c.measureText(text);
    if (Utils.mFontMetricsBuffer) {

      let lineHeight = Utils.mFontMetricsBuffer.height;

      // To have a consistent point of reference, we always draw left-aligned
      let originalTextAlign: CanvasTextAlign = paint.getTextAlign();
      let originalTextBaseLine: CanvasTextBaseline = paint.getTextBaseline();

      paint.setTextAlign('left');
      paint.setTextBaseline('top');
      Utils.resetContext2DWithoutLine(c, paint);
      if (angleDegrees != 0.0) {

        // Move the text drawing rect in a way that it always rotates around its center
        drawOffsetX -= Utils.mFontMetricsBuffer.width * 0.5;
        drawOffsetY -= lineHeight * 0.5;

        let translateX: number = x;
        let translateY: number = y;

        // Move the "outer" rect relative to the anchor, assuming its centered
        if (anchor.x != 0.5 || anchor.y != 0.5) {
          const rotatedSize: FSize = Utils.getSizeOfRotatedRectangleByDegrees(
            Utils.mFontMetricsBuffer.width,
            lineHeight,
            angleDegrees);

          translateX -= rotatedSize.width * (anchor.x - 0.5);
          if (labelPosition == XAxisLabelPosition.Right) {
            translateX += rotatedSize.width * 0.5;
          } else if (labelPosition == XAxisLabelPosition.Left) {
            translateX -= rotatedSize.width * 0.5;
          }
          translateY -= rotatedSize.height * (anchor.y - 0.5);
          FSize.recycleInstance(rotatedSize);
        }

        c.save();
        c.translate(translateX, translateY);
        c.rotate(angleDegrees * Math.PI / 180);
        switch (paint.getStyle()) {
          case Style.STROKE:
            c.beginPath();
            c.strokeText(text, drawOffsetX, drawOffsetY);
            c.closePath();
            break
          case Style.FILL_AND_STROKE:
          case Style.FILL:
          default:
            c.beginPath();
            c.fillText(text, drawOffsetX, drawOffsetY);
            c.closePath();
            break
        }
        c.restore();
      } else {
        if (anchor.x != 0.0 || anchor.y != 0.0) {

          drawOffsetX -= Utils.mFontMetricsBuffer.width * anchor.x;
          drawOffsetY -= lineHeight * anchor.y;
        }

        drawOffsetX += x;
        if (labelPosition == XAxisLabelPosition.Right) {
          drawOffsetX += Utils.mFontMetricsBuffer.width * 0.5;
        } else if (labelPosition == XAxisLabelPosition.Left) {
          drawOffsetX -= Utils.mFontMetricsBuffer.width * 0.5;
        }
        drawOffsetY += y;

        if(isHorizontalFlip){
          c.save();
          c.scale(-1,1);
        }
        switch (paint.getStyle()) {
          case Style.STROKE:
            c.beginPath();
            if(isHorizontalFlip){
              c.strokeText(text, -drawOffsetX - Utils.calcTextWidth(paint, text), drawOffsetY);
            }else{
              c.strokeText(text, drawOffsetX, drawOffsetY);
            }
            c.closePath();
            break
          case Style.FILL_AND_STROKE:
          case Style.FILL:
          default:
            c.beginPath();
            if(isHorizontalFlip){
              c.fillText(text, -drawOffsetX - Utils.calcTextWidth(paint, text), drawOffsetY);
            }else{
              c.fillText(text, drawOffsetX, drawOffsetY);
            }
            c.closePath();
            break
        }
        if(isHorizontalFlip){
          c.restore();
        }
      }

      paint.setTextAlign(originalTextAlign);
      paint.setTextBaseline(originalTextBaseLine);

    }
  }

  /**
   * Returns a recyclable FSize instance.
   * Represents size of a rotated rectangle by degrees.
   *
   * @param rectangleWidth
   * @param rectangleHeight
   * @param degrees
   * @return A Recyclable FSize instance
   */
  public static getSizeOfRotatedRectangleByDegrees(rectangleWidth: number,
                                                   rectangleHeight: number, degrees: number): FSize {
    let radians: number = degrees * Utils.FDEG2RAD;
    return Utils.getSizeOfRotatedRectangleByRadians(rectangleWidth, rectangleHeight, radians);
  }

  /**
   * Returns a recyclable FSize instance.
   * Represents size of a rotated rectangle by radians.
   *
   * @param rectangleWidth
   * @param rectangleHeight
   * @param radians
   * @return A Recyclable FSize instance
   */
  public static getSizeOfRotatedRectangleByRadians(rectangleWidth: number,
                                                   rectangleHeight: number, radians: number): FSize {
    return FSize.getInstance(
      Math.abs(rectangleWidth * Math.cos(radians)) + Math.abs(rectangleHeight *
      Math.sin(radians)),
      Math.abs(rectangleWidth * Math.sin(radians)) + Math.abs(rectangleHeight *
      Math.cos(radians))
    );
  }

  public static getSDKInt(): number {
    if (Utils.sdkInt != undefined) {
      return Utils.sdkInt;
    }
    Utils.sdkInt = deviceInfo.sdkApiVersion;
    return Utils.sdkInt;
  }

  public static resetContext2DFont(context2D: CanvasRenderer, paint: Paint) {
    context2D.font = paint.font;
  }

  public static resetContext2DStyle(context2D: CanvasRenderer, paint: Paint) {
    Utils.resetContext2DWithoutFont(context2D, paint);
    context2D.font = paint.font;
    context2D.textAlign = paint.textAlign;
    context2D.textBaseline = paint.textBaseline;
  }

  public static resetContext2DWithoutLine(context2D: CanvasRenderer, paint: Paint) {
    Utils.resetContext2DColorAndAlpha(context2D, paint);
    context2D.font = paint.font;
    context2D.textAlign = paint.textAlign;
    context2D.textBaseline = paint.textBaseline;
  }

  public static resetContext2DWithoutFont(context2D: CanvasRenderer, paint: Paint) {
    Utils.resetContext2DColorAndAlpha(context2D, paint);
    context2D.lineWidth = paint.lineWidth;

    let dashEffect = paint.getDashPathEffect();
    if (dashEffect) {
      context2D.setLineDash(dashEffect.dash);
      context2D.lineDashOffset = dashEffect.offset;
    } else {
      context2D.setLineDash([]);
    }
  }

  public static resetContext2DColorAndAlpha(context2D: CanvasRenderer, paint: Paint) {
    switch (paint.styleType) {
      case Style.FILL:
        context2D.fillStyle = paint.fillStyle;
        break;
      case Style.STROKE:
        context2D.strokeStyle = paint.strokeStyle;
        break;
      case Style.FILL_AND_STROKE:
      default:
        context2D.fillStyle = paint.fillStyle;
        context2D.strokeStyle = paint.strokeStyle;
        break;
    }
    if (paint.globalAlpha !== undefined) {
      context2D.globalAlpha = paint.globalAlpha;
    } else {
      context2D.globalAlpha = 1;
    }
  }

  public static parseInt(num: number): number {
    let stringNum = String(num);
    if (stringNum.includes('.')) {
      let numArr = stringNum.split('.');
      return Number(numArr[0]);
    }
    return num;
  }

  public static isHighLightEquals(highLight1: Highlight | null, highLight2: Highlight | null): boolean {
    if (highLight1 == undefined && highLight2 == undefined) {
      return true;
    }

    if (highLight1 == null && highLight2 == null) {
      return true;
    }

    if (highLight1 && highLight2) {
      return highLight1.getX() == highLight2.getX() && highLight1.getY() == highLight2.getY() && highLight1.getStackIndex() == highLight2.getStackIndex();
    } else {
      return false;
    }
  }

  public static equalsIgnoreCase(label: string, anotherString: string) {
    if (label === anotherString) {
      return true;
    }
    if (typeof anotherString === 'string') {
      return label.toLowerCase() == anotherString.toLowerCase(); //
    }
    return false;
  }

  /**
   * 绘制顶部圆角矩形
   * @param c 画布对象
   * @param left 矩形左边界的x坐标
   * @param top 矩形上边界的y坐标
   * @param width 矩形的宽度
   * @param height 矩形的高度
   * @param radius 圆角的半径
   * @param cornerType 矩形圆角绘制位置类型，顶部/底部/都有
   */
  public static fillRoundedRect(c: CanvasRenderingContext2D, left: number, top: number, width: number, height: number, radius: number, cornerType: RoundCornerType = 'up') {
    if (width == 0 || height == 0) {
      return;
    }
    if (width > height && radius >= width / 2) {
      switch (cornerType) {
        case 'down':
          c.moveTo(left, top);
          c.arc(left + width / 2, top, width / 2, 0, Math.PI, false);
          c.lineTo(left, top);
          break;
        case 'both':
          c.arc(left + width / 2, top + height / 2, width / 2, 0, Math.PI * 2);
          break;
        case 'up':
          c.moveTo(left, top + height);
          c.arc(left + width / 2, top + height, width / 2, 0, Math.PI, true);
          c.lineTo(left, top + height);
          break;
      }
      return;
    }
    // 避免宽度或高度小于 radius 时绘制异常，需要比较 width 和 height 最小值
    const min = Math.min(width, height)
    if (radius > min / 2) {
      radius = min / 2;
    }

    switch (cornerType) {
      case 'down':
        c.moveTo(left, top)
        c.lineTo(left + width, top)
        c.arcTo(left + width, top + height, left, top + height, radius)
        c.lineTo(left + radius, top + height)
        c.arcTo(left, top + height, left, top, radius)
        break
      case 'both':
        c.moveTo(left + radius, top);
        c.arcTo(left + width, top, left + width, top + height, radius);
        c.arcTo(left + width, top + height, left, top + height, radius)
        c.arcTo(left, top + height, left, top, radius)
        c.arcTo(left, top, left + radius, top, radius)
        break
      case 'up':
      default:
        c.moveTo(left + radius, top);
        c.arcTo(left + width, top, left + width, top + height, radius);
        c.lineTo(left + width, top + height);
        c.lineTo(left, top + height);
        c.arcTo(left, top, left + width, top, radius);
        break
    }
  }

  public static drawFillRect(isDrawRounded: boolean, c: CanvasRenderingContext2D, paint: Paint, left: number, top: number, right: number, bottom: number, radius: number, cornerType: RoundCornerType = 'up') {
    Utils.drawRect(isDrawRounded, c, paint, left, top, right, bottom, radius, true, cornerType);
  }

  public static drawStrokeRect(isDrawRounded: boolean, c: CanvasRenderingContext2D, paint: Paint, left: number, top: number, right: number, bottom: number, radius: number, cornerType: RoundCornerType = 'up') {
    Utils.drawRect(isDrawRounded, c, paint, left, top, right, bottom, radius, false, cornerType);
  }

  private static drawRect(isDrawRounded: boolean, c: CanvasRenderingContext2D, paint: Paint, left: number, top: number, right: number, bottom: number, radius: number, isFill: boolean, cornerType: RoundCornerType = 'up'): void {
    if (left - right == 0 || top - bottom == 0) {
      return;
    }
    Utils.resetContext2DWithoutFont(c, paint);
    c.beginPath();
    if (isDrawRounded && radius != 0) {
      Utils.fillRoundedRect(c, left, top, right - left, bottom - top, radius, cornerType);
    } else {
      c.rect(left, top, right - left, bottom - top);
    }
    if (isFill) {
      c.fill();
    } else {
      c.stroke();
    }
    c.closePath();
  }
}

/**
 * 矩形圆角绘制位置类型，顶部/底部/都有
 */
export type RoundCornerType = 'up' | 'down' | 'both'

export type PanActionType = 'Down' | 'Move' | 'Up';

export type LongPressType = 'Down' | 'Up' | 'Cancel';

export type PinchActionType = 'Start' | 'Update' | 'End' | 'Cancel';
