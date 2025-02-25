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

/**
 * 画笔属性类，用于绘制时使用画笔属性
 * @param value
 */
export default class Paint {
  styleType: Style = Style.FILL_AND_STROKE;
  globalAlpha: number | undefined = undefined;
  globalCompositeOperation: string = 'source-over'
  fillStyle: string | number | CanvasGradient | CanvasPattern = Color.White;
  strokeStyle: string | number | CanvasGradient | CanvasPattern = Color.Black;
  imageSmoothingEnabled: boolean = true;
  imageSmoothingQuality: ImageSmoothingQuality = 'low';
  lineCap: CanvasLineCap = 'butt'
  lineDashOffset: number = 0.0;
  lineJoin: CanvasLineJoin = 'miter'
  lineWidth: number = 1;
  miterLimit: number = 10;
  shadowBlur: number = 0.0;
  shadowColor: string = '#00000000';
  shadowOffsetX: number = 0;
  shadowOffsetY: number = 0;
  direction: CanvasDirection = 'inherit';
  fontStyle: FontStyleType = 'normal';
  fontWeight: FontWeightType = 'normal';
  fontSize: number = 14;
  fontSizeUnit: FontSizeUnit = 'vp';
  fontFamily: FontFamily = '';
  font: string = 'normal normal 14vp '
  textAlign: CanvasTextAlign = 'left';
  textBaseline: CanvasTextBaseline = 'alphabetic';
  lineDash: number[] = [];
  dashPathEffect: DashPathEffect | null = null;

  constructor(paint?: Paint) {
    if (paint != null && paint != undefined) {
      this.set(paint);
    }
  }


  public set(paint: Paint) {
    this.styleType = paint.styleType;
    this.globalAlpha = paint.globalAlpha
    this.globalCompositeOperation = paint.globalCompositeOperation;
    this.fillStyle = paint.fillStyle;
    this.strokeStyle = paint.strokeStyle;
    this.imageSmoothingEnabled = paint.imageSmoothingEnabled;
    this.imageSmoothingQuality = paint.imageSmoothingQuality;
    this.lineCap = paint.lineCap;
    this.lineDashOffset = paint.lineDashOffset;
    this.lineJoin = paint.lineJoin;
    this.lineWidth = paint.lineWidth;
    this.miterLimit = paint.miterLimit;
    this.shadowBlur = paint.shadowBlur;
    this.shadowColor = paint.shadowColor;
    this.shadowOffsetX = paint.shadowOffsetX;
    this.shadowOffsetY = paint.shadowOffsetY;
    this.direction = paint.direction;
    this.fontStyle = paint.fontStyle;
    this.fontWeight = paint.fontWeight;
    this.fontSize = paint.fontSize;
    this.fontSizeUnit = paint.fontSizeUnit;
    this.fontFamily = paint.fontFamily;
    this.font = paint.font;
    this.textAlign = paint.textAlign;
    this.textBaseline = paint.textBaseline;
    this.lineDash = paint.lineDash;
    this.dashPathEffect = paint.dashPathEffect;
  }

  public setColor(color: string | number | CanvasGradient | CanvasPattern) {
    this.fillStyle = color;
    this.strokeStyle = color;
  }

  public getColor(): string | number | CanvasGradient | CanvasPattern {
    return this.fillStyle;
  }

  public setStyle(styleType: Style) {
    this.styleType = styleType;
  }

  public getStyle(): Style {
    return this.styleType;
  }

  public setGlobalAlpha(alpha: number) {
    this.globalAlpha = alpha;
  }

  public getGlobalAlpha() {
    return this.globalAlpha;
  }

  public setGlobalCompositeOperation(composite: string) {
    this.globalCompositeOperation = composite;
  }

  public getGlobalCompositeOperation() {
    return this.globalCompositeOperation;
  }

  public setFillStyle(fillStyle: string | number | CanvasGradient | CanvasPattern) {
    this.fillStyle = fillStyle;
  }

  public getFillStyle(): string | number | CanvasGradient | CanvasPattern {
    return this.fillStyle;
  }

  public setStrokeStyle(strokeStyle: string | number | CanvasGradient | CanvasPattern) {
    this.strokeStyle = strokeStyle;
  }

  public getStrokeStyle(): string | number | CanvasGradient | CanvasPattern {
    return this.fillStyle;
  }

  public setImageSmoothingEnabled(enable: boolean) {
    this.imageSmoothingEnabled = enable;
  }

  public getImageSmoothingEnabled(): boolean {
    return this.imageSmoothingEnabled;
  }

  public setImageSmoothingQuality(quality: ImageSmoothingQuality) {
    this.imageSmoothingQuality = quality;
  }

  public getImageSmoothingQuality(): ImageSmoothingQuality {
    return this.imageSmoothingQuality;
  }

  public setLineCap(lineCap: CanvasLineCap) {
    this.lineCap = lineCap;
  }

  public getLineCap(): CanvasLineCap {
    return this.lineCap;
  }

  public setLineDashOffset(offset: number) {
    this.lineDashOffset = offset;
  }

  public getLineDashOffset(): number {
    return this.lineDashOffset;
  }

  public setLineJoin(lineJoin: CanvasLineJoin) {
    this.lineJoin = lineJoin;
  }

  public getLineJoin(): CanvasLineJoin {
    return this.lineJoin;
  }

  public setStrokeWidth(lineWidth: number) {
    this.lineWidth = lineWidth;
  }

  public getStrokeWidth(): number {
    return this.lineWidth;
  }

  public setMiterLimit(miterLimit: number) {
    this.miterLimit = miterLimit;
  }

  public getMiterLimit(): number {
    return this.miterLimit;
  }

  public setShadowBlur(shadowBlur: number) {
    this.shadowBlur = shadowBlur;
  }

  public getShadowBlur(): number {
    return this.miterLimit;
  }

  public setShadowColor(shadowColor: string) {
    this.shadowColor = shadowColor;
  }

  public getShadowColor(): string {
    return this.shadowColor;
  }

  public setShadowOffsetX(shadowOffsetX: number) {
    this.shadowOffsetX = shadowOffsetX;
  }

  public getShadowOffsetX(): number {
    return this.shadowOffsetX;
  }

  public setShadowOffsetY(shadowOffsetY: number) {
    this.shadowOffsetY = shadowOffsetY;
  }

  public getShadowOffsetY(): number {
    return this.shadowOffsetY;
  }

  public setDirection(direction: CanvasDirection) {
    this.direction = direction;
  }

  public getDirection(): CanvasDirection {
    return this.direction;
  }

  public setTextSize(textSize: number, textSizeUnit?: FontSizeUnit): void {
    this.fontSize = textSize;
    if (textSizeUnit) {
      this.fontSizeUnit = textSizeUnit;
    }
    this.font = this.fontStyle + " " + this.fontWeight + " " + this.fontSize + this.fontSizeUnit + " " + this.fontFamily;
  }

  public getTextSize(): number {
    return this.fontSize;
  }

  public setFontStyle(fontStyle: FontStyleType): void {
    this.fontStyle = fontStyle;
    this.font = this.fontStyle + " " + this.fontWeight + " " + this.fontSize + this.fontSizeUnit + " " + this.fontFamily;
  }

  public getFontStyle(): FontStyleType {
    return this.fontStyle;
  }

  public setFontWeight(fontWeight: FontWeightType): void {
    this.fontWeight = fontWeight;
    this.font = this.fontStyle + " " + this.fontWeight + " " + this.fontSize + this.fontSizeUnit + " " + this.fontFamily;
  }

  public getFontWeight(): FontWeightType {
    return this.fontWeight;
  }

  public setFontFamily(fontFamily: FontFamily): void {
    this.fontFamily = fontFamily;
    this.font = this.fontStyle + " " + this.fontWeight + " " + this.fontSize + this.fontSizeUnit + " " + this.fontFamily;
  }

  public getFontFamily(): FontFamily {
    return this.fontFamily;
  }

  public setFont(fontStyle?: FontStyleType, fontWeight?: FontWeightType, fontSize?: number, fontSizeUnit?: FontSizeUnit, fontFamily?: FontFamily) {
    if (!fontStyle) {
      this.fontStyle = 'normal';
    }
    if (!fontWeight) {
      this.fontWeight = 'normal'
    }
    if (!fontSize) {
      this.fontSize = 14;
    }
    if (!fontSizeUnit) {
      this.fontSizeUnit = 'px';
    }
    if (!fontFamily) {
      this.fontFamily = '';
    }
    this.font = this.fontStyle + " " + this.fontWeight + " " + this.fontSize + this.fontSizeUnit + " " + this.fontFamily;
  }

  public getFont(): string {
    return this.font;
  }

  public setTextAlign(textAlign: CanvasTextAlign) {
    this.textAlign = textAlign;
  }

  public getTextAlign(): CanvasTextAlign {
    return this.textAlign;
  }

  public setTextBaseline(textBaseline: CanvasTextBaseline) {
    this.textBaseline = textBaseline;
  }

  public getTextBaseline(): CanvasTextBaseline {
    return this.textBaseline;
  }

  public setLineDash(lineDash: number[]) {
    this.lineDash = lineDash;
  }

  public getLineDash(): number[] {
    return this.lineDash;
  }

  public setDashPathEffect(dashEffect: DashPathEffect | null) {
    this.dashPathEffect = dashEffect;
  }

  public getDashPathEffect(): DashPathEffect | null {
    return this.dashPathEffect;
  }
}

export class TextPaint extends Paint {
  text: string = "";

  constructor(paint?: TextPaint) {
    super(paint)
    if (paint != null && paint != undefined) {
      this.text = paint.text;
    }
  }

  translateX: number = 0;
  translateY: number = 0;
  rotate: number = 0;

  setText(value: string) {
    this.text = value
  }

  getText(): string {
    return this.text
  }

  setTranslateX(value: number) {
    this.translateX = value
  }

  getTranslateX(): number {
    return this.translateX
  }

  setTranslateY(value: number) {
    this.translateY = value
  }

  getTranslateY(): number {
    return this.translateY
  }

  setRotate(value: number) {
    this.rotate = value
  }

  getRotate(): number {
    return this.rotate
  }
}

export enum Style {
  FILL,
  STROKE,
  FILL_AND_STROKE
}

export class TextAlign {
  static CENTER: string = 'center';
  static END: string = 'end';
  static LEFT: string = 'left';
  static RIGHT: string = 'right';
  static START: string = 'start';
}

export type FontStyleType = 'normal' | 'italic';

export type FontWeightType = 'normal' | 'bold' | 'bolder' | 'lighter' | 100 | 200 | 300 | 400 | 500 | 600 | 700 | 800 | 900;

export type FontSizeUnit = 'px' | 'vp';

export type FontFamily = 'sans-serif' | 'serif' | 'monospace' | '';

export class DashPathEffect {
  dash: number[];
  offset: number

  constructor(dash: number[], offset: number) {
    this.dash = dash;
    this.offset = offset;
  }
}