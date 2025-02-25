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

import { DashPathEffect } from './Paint';
import { DataSet } from './DataSet';
import LineRadarDataSet from './LineRadarDataSet';
import EntryOhos from './EntryOhos';
import ILineDataSet from '../interfaces/datasets/ILineDataSet';
import IFillFormatter from '../formatter/IFillFormatter';
import DefaultFillFormatter from '../formatter/DefaultFillFormatter';
import { JArrayList } from '../utils/JArrayList';
import ColorTemplate, { ChartColor } from '../utils/ColorTemplate';
import { LogUtil } from '../utils/LogUtil';


export class LineDataSet extends LineRadarDataSet<EntryOhos> implements ILineDataSet {
  /**
   * Drawing mode for this line dataset
   **/
  private mMode: Mode = Mode.LINEAR;
  // private fillStyle: FillStyle = FillStyle.MIN;

  /**
   * List representing all colors that are used for the circles
   */
  private mCircleColors: JArrayList<Number> = new JArrayList<Number>();
  // private mCircleColor: number = Color.White;

  /**
   * the color of the inner circles
   */
  private mCircleHoleColor: number = Color.White;
  /**
   * the radius of the circle-shaped value indicators
   */
  private mCircleRadius: number = 8.0;
  /**
   * the hole radius of the circle-shaped value indicators
   */
  private mCircleHoleRadius: number = 4.0;
  /**
   * sets the intensity of the cubic lines
   */
  private mCubicIntensity: number = 0.2;
  /**
   * the path effect of this DataSet that makes dashed lines possible
   */
  private mDashPathEffect: DashPathEffect | null = null;
  /**
   * formatter for customizing the position of the fill-line
   */
  private mFillFormatter: IFillFormatter = new DefaultFillFormatter();
  /**
   * if true, drawing circles is enabled
   */
  private mDrawCircles: boolean = true;
  private mDrawCircleHole: boolean = true;

  constructor(yVals: JArrayList<EntryOhos> | null, label: string) {
    super(yVals, label);
    if (!this.mCircleColors) {
      this.mCircleColors = new JArrayList<Number>();
    }
    this.mCircleColors.clear();
    this.mCircleColors.add(ChartColor.rgb(140, 234, 255));
    // this.mCircleColors.add(0x8ceaff);

  }

  getCircleColor(index: number): number {
    return this.mCircleColors.get(index).valueOf();
  }

  public copy(): DataSet<EntryOhos> {
    let entries = new JArrayList<EntryOhos>();
    if (this.mEntries != null) {
      for (let i = 0; i < this.mEntries.size(); i++) {
        entries.add(this.mEntries.get(i).copy());
      }
    }
    let copied = new LineDataSet(entries, this.getLabel());
    this.copyTo(copied);
    return copied;
  }

  protected copyTo(lineDataSet: LineDataSet): void {
    super.copyTo(lineDataSet);
    lineDataSet.mCircleColors = this.mCircleColors;
    lineDataSet.mCircleHoleColor = this.mCircleHoleColor;
    lineDataSet.mCircleHoleRadius = this.mCircleHoleRadius;
    lineDataSet.mCircleRadius = this.mCircleRadius;
    lineDataSet.mCubicIntensity = this.mCubicIntensity;
    lineDataSet.mDashPathEffect = this.mDashPathEffect;
    lineDataSet.mDrawCircleHole = this.mDrawCircleHole;
    lineDataSet.mDrawCircles = this.mDrawCircleHole;
    lineDataSet.mFillFormatter = this.mFillFormatter;
    lineDataSet.mMode = this.mMode;
  }

  /**
   * Returns the drawing mode for this line dataset
   *
   * @return
   */
  public getMode(): Mode {
    return this.mMode;
  }

  /**
   * Returns the drawing mode for this LineDataSet
   *
   * @return
   */
  public setMode(mode: Mode): void {
    this.mMode = mode;
  }

  /**
   * Sets the intensity for cubic lines (if enabled). Max = 1f = very cubic,
   * Min = 0.05f = low cubic effect, Default: 0.2f
   *
   * @param intensity
   */
  public setCubicIntensity(intensity: number): void {
    if (intensity > 1)
      intensity = 1;
    if (intensity < 0.05)
      intensity = 0.05;
    ;
    this.mCubicIntensity = intensity;
  }

  public getCubicIntensity(): number {
    return this.mCubicIntensity;
  }

  /**
   * Sets the radius of the drawn circles.
   * Default radius = 4f, Min = 1f
   *
   * @param radius
   */
  public setCircleRadius(radius: number): void {

    if (radius >= 1) {
      //      this.mCircleRadius = Utils.convertDpToPixel(radius);
      this.mCircleRadius = radius;
    } else {
      LogUtil.log("LineDataSet", "Circle radius cannot be < 1")
    }
  }

  public getCircleRadius(): number {
    return this.mCircleRadius;
  }

  /**
   * Sets the hole radius of the drawn circles.
   * Default radius = 2f, Min = 0.5f
   *
   * @param holeRadius
   */
  public setCircleHoleRadius(holeRadius: number): void {

    if (holeRadius >= 0.5) {
      //      this.mCircleHoleRadius = Utils.convertDpToPixel(holeRadius);
      this.mCircleHoleRadius = holeRadius;
    } else {
      LogUtil.log("LineDataSet", "Circle radius cannot be < 0.5")
    }
  }

  public getCircleHoleRadius(): number {
    return this.mCircleHoleRadius;
  }

  /**
   * sets the size (radius) of the circle shpaed value indicators,
   * default size = 4f
   * <p/>
   * This method is deprecated because of unclarity. Use setCircleRadius instead.
   *
   * @param size
   */
  //      @Deprecated
  public setCircleSize(size: number): void {
    this.setCircleRadius(size);
  }

  /**
   * This function is deprecated because of unclarity. Use getCircleRadius instead.
   */
  //      @Deprecated
  public getCircleSize(): number {
    return this.getCircleRadius();
  }

  public enableDashedLine(lineLength: number, spaceLength: number, phase: number): void {
    this.mDashPathEffect = new DashPathEffect([lineLength, spaceLength], phase);
  }

  /**
   * Disables the line to be drawn in dashed mode.
   */
  public disableDashedLine(): void {
    this.mDashPathEffect = null;
  }

  public isDashedLineEnabled(): boolean {
    return this.mDashPathEffect == null ? false : true;
  }

  public getDashPathEffect(): DashPathEffect | null {
    return this.mDashPathEffect;
  }

  /**
   * set this to true to enable the drawing of circle indicators for this
   * DataSet, default true
   *
   * @param enabled
   */
  public setDrawCircles(enabled: boolean): void {
    this.mDrawCircles = enabled;
  }

  public isDrawCirclesEnabled(): boolean {
    return this.mDrawCircles;
  }

  //      @Deprecated
  public isDrawCubicEnabled(): boolean {
    return this.mMode == Mode.CUBIC_BEZIER;
  }

  //      @Deprecated
  public isDrawSteppedEnabled(): boolean {
    return this.mMode == Mode.STEPPED;
  }

  /** ALL CODE BELOW RELATED TO CIRCLE-COLORS */

  /**
   * returns all colors specified for the circles
   *
   * @return
   */
  public getCircleColors(): JArrayList<Number> | null {
    return this.mCircleColors;
  }

  public getCircleColorByIndex(index: number): number {
    if (this.mCircleColors) {
      return this.mCircleColors.get(index).valueOf();
    }
    return 0;
  }

  public getCircleColorCount(): number {
    if (this.mCircleColors) {
      return this.mCircleColors.length();
    }
    return 0;
  }


  public setCircleColorsByArray(colors: JArrayList<number>): void {
    this.mCircleColors = colors;
  }

  public setCircleColors(colors: number[]): void {
    this.mCircleColors = ColorTemplate.createColors(colors);
  }

  public setCircleColorsByArrayAndCon(colors: number[]): void {
    let clrs: JArrayList<Number> | null = this.mCircleColors;
    if (clrs == null) {
      clrs = new JArrayList();
    }
    clrs.clear();
    for (let color of colors) {
      clrs.add(color);
    }
    this.mCircleColors = clrs;
  }

  /**
   * Sets the one and ONLY color that should be used for this DataSet.
   * Internally, this recreates the colors array and adds the specified color.
   *
   * @param color
   */
  public setCircleColor(color: number): void {
    this.resetCircleColors();
    if (this.mCircleColors) {
      // this.mCircleColor = color;
      this.mCircleColors.add(color);
    }
  }

  // public getCircleColor(): number  {
  //   return this.mCircleColor;
  // }

  /**
   * resets the circle-colors array and creates a new one
   */
  public resetCircleColors(): void {
    if (this.mCircleColors == null) {
      this.mCircleColors = new JArrayList<Number>();
    }
    this.mCircleColors.clear();
  }

  /**
   * Sets the color of the inner circle of the line-circles.
   *
   * @param color
   */
  public setCircleHoleColor(color: number): void {
    this.mCircleHoleColor = color;
  }

  public getCircleHoleColor(): number {
    return this.mCircleHoleColor;
  }

  /**
   * Set this to true to allow drawing a hole in each data circle.
   *
   * @param enabled
   */
  public setDrawCircleHole(enabled: boolean): void {
    this.mDrawCircleHole = enabled;
  }

  public isDrawCircleHoleEnabled(): boolean {
    return this.mDrawCircleHole;
  }

  /**
   * Sets a custom IFillFormatter to the chart that handles the position of the
   * filled-line for each DataSet. Set this to null to use the default logic.
   *
   * @param formatter
   */
  public setFillFormatter(formatter: IFillFormatter): void {

    if (!formatter) {
      this.mFillFormatter = new DefaultFillFormatter();
    } else {
      this.mFillFormatter = formatter;
    }
  }

  public getFillFormatter(): IFillFormatter {
    return this.mFillFormatter;
  }

  getDashPathEffectHighlight(): DashPathEffect | null {
    return this.mHighlightDashPathEffect;
  }


  // public setFillStyle(fillStyle: FillStyle) {
  //   this.fillStyle = fillStyle;
  // }
  //
  // public getFillStyle(): FillStyle | null {
  //   return this.fillStyle;
  // }
}

// export type ColorStop = [Color | string | number,number];
export type ChartColorStop = [string, number];

export enum Mode {
  LINEAR,
  STEPPED,
  CUBIC_BEZIER,
  HORIZONTAL_BEZIER
}

//
// export enum FillStyle {
//   MIN,
//   MAX
// }

