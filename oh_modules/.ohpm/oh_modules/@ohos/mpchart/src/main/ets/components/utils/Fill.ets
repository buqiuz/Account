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

import Paint, { Style } from '../data/Paint';
import MyRect from '../data/Rect';
import Utils, { RoundCornerType } from '../utils/Utils';
import ChartPixelMap from '../data/ChartPixelMap';

export enum FillType {
  EMPTY, COLOR, LINEAR_GRADIENT, DRAWABLE
}

export enum FillDirection {
  DOWN, UP, RIGHT, LEFT
}

export default class Fill {
  /**
   * the type of fill
   */
  private mType: FillType = FillType.EMPTY;
  /**
   * the color that is used for filling
   */
  private mColor: string | number = '#ffffff';
  private mFinalColor: number = 0;
  /**
   * the drawable to be used for filling
   */
  protected mDrawable: ChartPixelMap | null = null;
  private mGradientColors: string[] | null = null;
  private mGradientPositions: number[] | null = null;
  /**
   * transparency used for filling
   */
  private mAlpha: number = 255;

  constructor();

  constructor(color: number | string);

  constructor(startColor: number | string, endColor: number | string);

  constructor(gradientColors: string[]);

  constructor(gradientColors: string[], gradientPositions: number[]);

  constructor(drawable: ChartPixelMap);

  constructor(color?: number | string | string[] | ChartPixelMap, endColor?: number | string | number[]) {
    if (typeof color == 'object') {
      if (color instanceof ChartPixelMap) {
        this.mType = FillType.DRAWABLE;
        this.mDrawable = color;
      } else {
        this.mType = FillType.LINEAR_GRADIENT;
        this.mGradientColors = color;
      }
    } else {
      if (endColor) {
        if (typeof color == 'string' && typeof endColor == 'string') {
          this.mType = FillType.LINEAR_GRADIENT;
          this.mGradientColors = [color, endColor];
        } else if (typeof color == 'object' && typeof endColor == 'object') {
          this.mType = FillType.LINEAR_GRADIENT;
          this.mGradientColors = color;
          this.mGradientPositions = endColor;
        }
      } else {
        if (color) {
          this.mType = FillType.COLOR;
          this.mColor = color;
          this.calculateFinalColor();
        }
      }
    }
  }

  // constructor (color?:number,startColor?:number,endColor?:number,gradientColors?:number[],gradientPositions?:number[],drawable?:ImagePaint){
  //   if(color!=null&&color!=undefined){
  //     this.mType = Type.COLOR;
  //     this.mColor = color;
  //     this.calculateFinalColor();
  //     return
  //   }
  //   if(startColor!=null&&startColor!=undefined&&endColor!=null&&endColor!=undefined){
  //     this.mType = Type.LINEAR_GRADIENT;
  //     this.mGradientColors = [startColor, endColor];
  //     this.mGradientPositions = [0.0, 1.0];
  //     return
  //   }
  //   if(gradientColors!=null&&gradientColors!=undefined && !!gradientPositions){
  //     this.mType = Type.LINEAR_GRADIENT;
  //     this.mGradientColors = gradientColors;
  //     this.mGradientPositions = gradientPositions;
  //     return
  //   }
  //   if(drawable!=null&&drawable!=undefined){
  //     this.mType = Type.DRAWABLE;
  //     this.mDrawable = drawable;
  //     return
  //   }
  // }

  public getType(): FillType {
    return this.mType;
  }

  public setType(type: FillType): void {
    this.mType = type;
  }

  public getColor(): number | string {
    return this.mColor !;
  }

  public setColor(color: string): void {
    this.mColor = color;
    this.calculateFinalColor();
  }

  public getGradientColors(): string[] {
    return this.mGradientColors !;
  }

  public getGradientPositions(): number[] {
    return this.mGradientPositions !;
  }

  public setGradientPositions(positions: number[]): void {
    this.mGradientPositions = positions;
  }

  public setGradientColors(colors: string[]): void;

  public setGradientColors(startColor: string, endColor: string): void;

  public setGradientColors(color: string | string[], endColor?: string): void {
    if (typeof color == 'object') {
      this.mGradientColors = color;
    } else if (typeof color == 'string' && typeof endColor == 'string') {
      this.mGradientColors = [color, endColor];
    }
  }

  public getAlpha(): number {
    return this.mAlpha;
  }

  public setAlpha(alpha: number): void {
    this.mAlpha = alpha;
    this.calculateFinalColor();
  }

  private calculateFinalColor(): void {

    if (this.mColor == 0) {
      this.mFinalColor = 0;
    } else {
      if (typeof this.mColor == 'number') {
        let alpha: number = Math.floor(((this.mColor >> 24) / 255.0) * (this.mAlpha / 255.0) * 255.0);
        this.mFinalColor = (alpha << 24) | (this.mColor & 0xffffff);
      }
    }
  }

  public async fillRect(c: CanvasRenderingContext2D, paint: Paint, left: number, top: number, right: number, bottom: number,
                  gradientDirection: FillDirection, radius?: number, cornerType: RoundCornerType = 'up'): Promise<void> {
    switch (this.mType) {
      case FillType.EMPTY:
        return;
      case FillType.COLOR:
        if (this.mFinalColor == null) return;
        if (this.isClipPathSupported()) {

          c.save();
          if (radius != undefined && radius > 0) {
            Utils.fillRoundedRect(c, left, top, right - left, bottom - top, radius, cornerType);
          }else{
            c.rect(left, top, right - left, bottom - top);
          }
          c.clip();
          c.fillStyle = this.mFinalColor;
          c.fill();
          c.restore()
        } else {
          // save
          let previous: Style = paint.getStyle();
          let previousColor: number = (paint.getColor() as number);

          // set
          paint.setStyle(Style.FILL);
          paint.setColor(this.mFinalColor);
          Utils.resetContext2DWithoutFont(c, paint);
          c.beginPath();
          if(radius != undefined && radius > 0){
            Utils.fillRoundedRect(c, left, top, right - left, bottom - top, radius, cornerType);
          }else{
            c.fillRect(left, top, right - left, bottom - top);
          }
          c.closePath();

          // restore
          paint.setColor(previousColor);
          paint.setStyle(previous);
          // return rectP;

        }
        break;
      case FillType.LINEAR_GRADIENT:

        let gradient = c.createLinearGradient(Math.floor(gradientDirection == FillDirection.RIGHT ? right : gradientDirection == FillDirection.LEFT ? left : left),
          Math.floor(gradientDirection == FillDirection.UP ? bottom : gradientDirection == FillDirection.DOWN ? top : top),
          Math.floor(gradientDirection == FillDirection.RIGHT ? left : gradientDirection == FillDirection.LEFT ? right : left),
          Math.floor(gradientDirection == FillDirection.UP ? top : gradientDirection == FillDirection.DOWN ? bottom : top))
        if (this.mGradientColors && this.mGradientColors.length == 2) {
          for (let i = 0; i < this.mGradientColors.length; i++) {
            gradient.addColorStop(i, this.mGradientColors[i]);
          }
        }

        paint.setFillStyle(gradient);
        Utils.resetContext2DWithoutFont(c, paint);
        c.beginPath();
        if(radius != undefined && radius > 0){
          Utils.fillRoundedRect(c, left, top, right - left, bottom - top, radius, cornerType);
        }else{
          c.rect(left, top, right - left, bottom - top);
        }
        c.fill();
        c.closePath();
        break;

      case FillType.DRAWABLE:
        if (this.mDrawable == null) return;
        c.drawImage(await this.mDrawable.getIcon(), left, top, right - left, bottom - top);
        break;
    }
  }

  public async fillPath(c: CanvasRenderingContext2D, path: Path2D, paint: Paint, clipRect: MyRect): Promise<void> {
    // let defaultRect:BackGroundPaint=new BackGroundPaint();
    switch (this.mType) {
      case FillType.EMPTY:
        return;

      case FillType.COLOR:
        if (this.mFinalColor == null || this.mFinalColor == undefined) return;

        if (clipRect != null && this.isClipPathSupported()) {
          c.save();
          c.beginPath();
          c.fill(path);
          c.clip();
          c.fillStyle = this.mFinalColor;
          c.fill()
          c.closePath();
          c.restore();
          // let rectP:BackGroundPaint=new BackGroundPaint();
          // rectP.setBackgroundColor(this.mFinalColor);
          // return rectP;
        } else {
          // save
          let previous: Style = paint.getStyle();
          let previousColor = paint.getColor();

          // set
          paint.setStyle(Style.FILL);
          paint.setColor(this.mFinalColor);
          Utils.resetContext2DWithoutFont(c, paint);
          c.beginPath();
          c.fill(path);
          c.closePath();
          // let pathP:PathPaint=new PathPaint(paint);
          // pathP.setCommands(path)
          // // restore
          paint.setColor(previousColor);
          if (previous) {
            paint.setStyle(previous);
          }
          // return pathP;
        }
        break;
      case FillType.LINEAR_GRADIENT:
        if (this.mGradientColors == null) return;
        let gradient = c.createLinearGradient(0, 0, c.width, c.height);
        if (this.mGradientColors && this.mGradientColors.length == 2) {
          for (let i = 0; i < this.mGradientColors.length; i++) {
            gradient.addColorStop(i, this.mGradientColors[i]);
          }
        }
        paint.setFillStyle(gradient);
        Utils.resetContext2DWithoutFont(c, paint);
        c.beginPath();
        c.fill(path);
        c.closePath();
      // let gradient:PathPaint=new PathPaint();
      // let leftResult:number=0
      // let topResult:number=0
      // let rightResult:number=chartWidth;
      // let bottomResult:number=chartHeight
      // gradient.setX(leftResult)
      // gradient.setY(topResult)
      // gradient.setWidth(rightResult-leftResult);
      // gradient.setHeight(bottomResult-topResult);
      // let colorArr:ColorStop[]=new Array<ColorStop>()
      // if (this.mGradientColors && this.mGradientPositions) {
      //   for(let i=0;i<this.mGradientColors.length;i++){
      //     colorArr.push([this.mGradientColors[i], this.mGradientPositions[i]])
      //   }
      // }
      // let paintStyle = paint.getStyle();
      // if (paintStyle) {
      //   gradient.setStyle(paintStyle);
      // }
      // gradient.setColor(paint.getColor());
      // gradient.setGradientFillColor(colorArr)
      // return gradient;
        break;
      case FillType.DRAWABLE:
        if (this.mDrawable == null) return;

        this.ensureClipPathSupported();

      //        this.mDrawable.setBounds(
      //            clipRect == null ? 0 : clipRect.left,
      //            clipRect == null ? 0 : clipRect.top,
      //            clipRect == null ?0 : clipRect.right,
      //            clipRect == null ? 0: clipRect.bottom);

      // let imagePaint=new ImagePaint(this.mDrawable);
      // let leftImage:number=(clipRect == null ? 0 : clipRect.left)
      // let topImage:number=(clipRect == null ? 0 : clipRect.top)
      // let rightImage:number=(clipRect == null ?chartWidth : clipRect.right)
      // let bottomImage:number=(clipRect == null ? chartHeight: clipRect.bottom)
      // imagePaint.x=leftImage;
      // imagePaint.y=topImage;
      // imagePaint.setWidth(rightImage-leftImage)
      // imagePaint.setHeight(bottomImage-topImage)
      //
      // return this.mDrawable;
        c.save();
        c.beginPath();
        c.fill(path);
        c.clip();
        c.closePath();
        let leftBounds: number = clipRect == null ? 0 : clipRect.left;
        let topBounds: number = clipRect == null ? 0 : clipRect.top;
        let rightBounds: number = clipRect == null ? c.width : clipRect.right;
        let bottomBounds: number = clipRect == null ? c.height : clipRect.bottom;
        let icon= await this.mDrawable.getIcon()
        if (icon) {
          c.drawImage(icon, leftBounds, topBounds, rightBounds - leftBounds, bottomBounds - topBounds);
        }
        c.restore();
    }
  }

  private isClipPathSupported(): boolean {
    return Utils.getSDKInt() >= 8;
  }

  private ensureClipPathSupported(): void {
    if (Utils.getSDKInt() < 8) {
      throw new Error("Fill-drawables not (yet) supported below API level 18, " +
      "this code was run on API level " + Utils.getSDKInt() + ".");
    }
  }
}
