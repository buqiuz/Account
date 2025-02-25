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

import { DataSet } from './DataSet';
import BarLineScatterCandleBubbleDataSet from './BarLineScatterCandleBubbleDataSet';
import BarEntry from './BarEntry';
import IBarDataSet from '../interfaces/datasets/IBarDataSet';
import { JList } from '../utils/JList';
import { JArrayList } from '../utils/JArrayList';
import Fill from '../utils/Fill';

export default class BarDataSet extends BarLineScatterCandleBubbleDataSet<BarEntry> implements IBarDataSet {
  /**
   * the maximum number of bars that are stacked upon each other, this value
   * is calculated from the Entries that are added to the DataSet
   */
  private mStackSize: number = 1;
  /**
   * the color used for drawing the bar shadows
   */
  private mBarShadowColor: number = 0xd7d7d7;
  private mBarBorderWidth: number = 0.0;
  private mBarBorderColor: number = Color.Black;
  /**
   * the alpha value used to draw the highlight indicator bar
   */
  private mHighLightAlpha: number = 120;
  /**
   * the overall entry count, including counting each stack-value individually
   */
  private mEntryCountStacks: number = 0;
  /**
   * array of labels used to describe the different values of the stacked bars
   */
  private mStackLabels: string[] = new Array<string>();
  protected mFills: JArrayList<Fill> | null = null;

  constructor(yVals: JArrayList<BarEntry>, label: string) {
    super(yVals, label);
    this.mHighLightColor = 0x000000;
    this.calcStackSize(yVals);
    this.calcEntryCountIncludingStacks(yVals);
  }

  public copy(): DataSet<BarEntry> {
    let entries = new JArrayList<BarEntry>();
    if (this.mEntries != null) {
      for (let i = 0; i < this.mEntries.size(); i++) {
        entries.add(this.mEntries.get(i).copy());
      }
    }
    let copied = new BarDataSet(entries, this.getLabel());
    this.copyTo(copied);
    return copied;
  }

  protected copyTo(barDataSet: BarDataSet): void {
    super.copyTo(barDataSet);
    barDataSet.mStackSize = this.mStackSize;
    barDataSet.mBarShadowColor = this.mBarShadowColor;
    barDataSet.mBarBorderWidth = this.mBarBorderWidth;
    barDataSet.mStackLabels = this.mStackLabels;
    barDataSet.mHighLightAlpha = this.mHighLightAlpha;
  }

  public getFills(): JArrayList<Fill> | null {
    return this.mFills;
  }

  public getFill(index: number): Fill | null {
    if (this.mFills) {
      return this.mFills.get(index % this.mFills.listSize);
    }
    return new Fill();
  }

  /**
   * This method is deprecated.
   * Use getFills() instead.
   */
  public getGradients(): JList<Fill> | null {
    return this.mFills;
  }

  /**
   * This method is deprecated.
   * Use getFill(...) instead.
   *
   * @param index
   */
  public getGradient(index: number): Fill | null {
    return this.getFill(index);
  }

  /**
   * Sets the start and end color for gradient color, ONLY color that should be used for this DataSet.
   *
   * @param startColor
   * @param endColor
   */
  public setGradientColor(startColor: number, endColor: number): void {
    if (this.mFills) {
      this.mFills.clear();
      this.mFills.insert(new Fill(startColor, endColor));
    }
  }

  /**
   * This method is deprecated.
   * Use setFills(...) instead.
   *
   * @param gradientColors
   */
  public setGradientColors(gradientColors: JArrayList<Fill>): void {
    this.mFills = gradientColors;
  }

  /**
   * Sets the fills for the bars in this dataset.
   *
   * @param fills
   */
  public setFills(fills: JArrayList<Fill>): void {
    this.mFills = fills;
  }

  /**
   * Calculates the total number of entries this DataSet represents, including
   * stacks. All values belonging to a stack are calculated separately.
   */
  private calcEntryCountIncludingStacks(yVals: JList<BarEntry>): void {

    this.mEntryCountStacks = 0;

    for (let i = 0; i < yVals.length(); i++) {

      let vals: number[] | null = yVals.get(i).getYVals();

      if (!vals)
        this.mEntryCountStacks++;
      else
        this.mEntryCountStacks += vals.length;
    }
  }

  /**
   * calculates the maximum stacksize that occurs in the Entries array of this
   * DataSet
   */
  private calcStackSize(yVals: JList<BarEntry>): void {

    for (let i = 0; i < yVals.length(); i++) {

      let vals: number[] | null = yVals.get(i).getYVals();

      if (vals != null && vals.length > this.mStackSize)
        this.mStackSize = vals.length;
    }
  }

  public myCalcMinMax(e: BarEntry): void {
    if (e != null && !Number.isNaN(e.getY())) {

      if (!e.getYVals()) {

        if (e.getY() < this.mYMin)
          this.mYMin = e.getY();

        if (e.getY() > this.mYMax)
          this.mYMax = e.getY();
      } else {

        if (-e.getNegativeSum() < this.mYMin)
          this.mYMin = -e.getNegativeSum();

        if (e.getPositiveSum() > this.mYMax)
          this.mYMax = e.getPositiveSum();
      }
      this.calcMinMaxX(e);
    }
  }

  public getStackSize(): number {
    return this.mStackSize;
  }

  public isStacked(): boolean {
    return this.mStackSize > 1 ? true : false;
  }

  /**
   * returns the overall entry count, including counting each stack-value
   * individually
   *
   * @return
   */
  public getEntryCountStacks(): number {
    return this.mEntryCountStacks;
  }

  /**
   * Sets the color used for drawing the bar-shadows. The bar shadows is a
   * surface behind the bar that indicates the maximum value. Don't for get to
   * use getResources().getColor(...) to set this. Or Color.rgb(...).
   *
   * @param color
   */
  public setBarShadowColor(color: number): void {
    this.mBarShadowColor = color;
  }

  public getBarShadowColor(): number {
    return this.mBarShadowColor;
  }

  /**
   * Sets the width used for drawing borders around the bars.
   * If borderWidth == 0, no border will be drawn.
   *
   * @return
   */
  public setBarBorderWidth(width: number): void {
    this.mBarBorderWidth = width;
  }

  /**
   * Returns the width used for drawing borders around the bars.
   * If borderWidth == 0, no border will be drawn.
   *
   * @return
   */
  public getBarBorderWidth(): number {
    return this.mBarBorderWidth;
  }

  /**
   * Sets the color drawing borders around the bars.
   *
   * @return
   */
  public setBarBorderColor(color: number): void {
    this.mBarBorderColor = color;
  }

  /**
   * Returns the color drawing borders around the bars.
   *
   * @return
   */
  public getBarBorderColor(): number {
    return this.mBarBorderColor;
  }

  /**
   * Set the alpha value (transparency) that is used for drawing the highlight
   * indicator bar. min = 0 (fully transparent), max = 255 (fully opaque)
   *
   * @param alpha
   */
  public setHighLightAlpha(alpha: number): void {
    this.mHighLightAlpha = alpha;
  }

  public getHighLightAlpha(): number {
    return this.mHighLightAlpha;
  }

  /**
   * Sets labels for different values of bar-stacks, in case there are one.
   *
   * @param labels
   */
  public setStackLabels(labels: string[]): void {
    this.mStackLabels = labels;
  }

  public getStackLabels(): string[] {
    return this.mStackLabels;
  }
}
