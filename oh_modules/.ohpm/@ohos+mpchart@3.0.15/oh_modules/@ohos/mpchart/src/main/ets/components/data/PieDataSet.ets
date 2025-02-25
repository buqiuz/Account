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

import IPieDataSet from '../interfaces/datasets/IPieDataSet';
import Utils from '../utils/Utils';
import { DataSet } from './DataSet';
import { JArrayList } from '../utils/JArrayList';
import PieEntry from './PieEntry';

export default class PieDataSet extends DataSet<PieEntry> implements IPieDataSet {
  /**
   * the space in pixels between the chart-slices, default 0f
   */
  private mSliceSpace: number = 0;
  private mAutomaticallyDisableSliceSpacing: boolean = false;
  /**
   * indicates the selection distance of a pie slice
   */
  private mShift: number = 18;
  private mXValuePosition: ValuePosition = ValuePosition.INSIDE_SLICE;
  private mYValuePosition: ValuePosition = ValuePosition.INSIDE_SLICE;
  private mValueLineColor: number = 0xff000000;
  private mUseValueColorForLine: boolean = false;
  private mValueLineWidth: number = 1.0;
  private mValueLinePart1OffsetPercentage: number = 75;
  private mValueLinePart1Length: number = 0.3;
  private mValueLinePart2Length: number = 0.4;
  private mValueLineVariableLength: boolean = true;
  private mHighlightColor: number | null = null;

  // private entry:JArrayList<PieEntry> = new JArrayList<PieEntry>()

  constructor(yVals: JArrayList<PieEntry>, label: string) {
    super(yVals, label);
    //        mShift = Utils.convertDpToPixel(12f);
  }

  // @Override
  // public DataSet<PieEntry> copy() {
  //     List<PieEntry> entries = new ArrayList<>();
  //     for (int i = 0; i < mEntries.size(); i++) {
  //         entries.add(mEntries.get(i).copy());
  //     }
  //     PieDataSet copied = new PieDataSet(entries, getLabel());
  //     copy(copied);
  //     return copied;
  // }
  //
  // protected void copy(PieDataSet pieDataSet) {
  //     super.copy(pieDataSet);
  // }
  public copy(): DataSet<PieEntry> {
    let entries = new JArrayList<PieEntry>();
    if (this.mEntries != null) {
      for (let i = 0; i < this.mEntries.size(); i++) {
        entries.add(this.mEntries.get(i).copy());
      }
    }
    let copied = new PieDataSet(entries, this.getLabel());
    this.copyTo(copied);
    return copied;
  }

  // @Override
  public myCalcMinMax(e: PieEntry): void {

    if (e == null)
      return;

    super.myCalcMinMax(e);
  }

  /**
   * Sets the space that is left out between the piechart-slices in vp.
   * Default: 0 --> no space, maximum 20f
   *
   * @param spaceDp
   */
  public setSliceSpace(spaceDp: number): void {
    if (spaceDp > 20)
      spaceDp = 20;
    if (spaceDp < 0)
      spaceDp = 0;

    this.mSliceSpace = Utils.handleDataValues(spaceDp);
  }


  // @Override
  public getSliceSpace(): number {
    return this.mSliceSpace;
  }

  /**
   * When enabled, slice spacing will be 0.0 when the smallest value is going to be
   * smaller than the slice spacing itself.
   *
   * @param autoDisable
   */
  public setAutomaticallyDisableSliceSpacing(autoDisable: boolean): void {
    this.mAutomaticallyDisableSliceSpacing = autoDisable;
  }

  /**
   * When enabled, slice spacing will be 0.0 when the smallest value is going to be
   * smaller than the slice spacing itself.
   *
   * @return
   */
  // @Override
  public isAutomaticallyDisableSliceSpacingEnabled(): boolean {
    return this.mAutomaticallyDisableSliceSpacing;
  }

  /**
   * sets the distance the highlighted piechart-slice of this DataSet is
   * "shifted" away from the center of the chart, default 12f
   *
   * @param shift
   */
  public setSelectionShift(shift: number): void {
    this.mShift = Utils.handleDataValues(shift);
  }

  // @Override
  public getSelectionShift(): number {
    return this.mShift;
  }

  // @Override
  public getXValuePosition(): ValuePosition {
    return this.mXValuePosition;
  }

  public setXValuePosition(xValuePosition: ValuePosition): void {
    this.mXValuePosition = xValuePosition;
  }

  // @Override
  public getYValuePosition(): ValuePosition {
    return this.mYValuePosition;
  }

  public setYValuePosition(yValuePosition: ValuePosition): void {
    this.mYValuePosition = yValuePosition;
  }

  /**
   * This method is deprecated.
   * Use isUseValueColorForLineEnabled() instead.
   */
  // @Deprecated
  public isUsingSliceColorAsValueLineColor(): boolean {
    return this.isUseValueColorForLineEnabled();
  }

  /**
   * This method is deprecated.
   * Use setUseValueColorForLine(...) instead.
   *
   * @param enabled
   */
  // @Deprecated
  public setUsingSliceColorAsValueLineColor(enabled: boolean): void {
    this.setUseValueColorForLine(enabled);
  }

  /**
   * When valuePosition is OutsideSlice, indicates line color
   */
  // @Override
  public getValueLineColor(): number {
    return this.mValueLineColor;
  }

  public setValueLineColor(valueLineColor: number): void {
    this.mValueLineColor = valueLineColor;
  }

  // @Override
  public isUseValueColorForLineEnabled(): boolean {
    return this.mUseValueColorForLine;
  }

  public setUseValueColorForLine(enabled: boolean): void {
    this.mUseValueColorForLine = enabled;
  }

  /**
   * When valuePosition is OutsideSlice, indicates line width
   */
  // @Override
  public getValueLineWidth(): number {
    return this.mValueLineWidth;
  }

  public setValueLineWidth(valueLineWidth: number): void {
    this.mValueLineWidth = valueLineWidth;
  }

  /**
   * When valuePosition is OutsideSlice, indicates offset as percentage out of the slice size
   */
  // @Override
  public getValueLinePart1OffsetPercentage(): number {
    return this.mValueLinePart1OffsetPercentage;
  }

  public setValueLinePart1OffsetPercentage(valueLinePart1OffsetPercentage: number): void {
    this.mValueLinePart1OffsetPercentage = valueLinePart1OffsetPercentage;
  }

  /**
   * When valuePosition is OutsideSlice, indicates length of first half of the line
   */
  // @Override
  public getValueLinePart1Length(): number {
    return this.mValueLinePart1Length;
  }

  public setValueLinePart1Length(valueLinePart1Length: number): void {
    this.mValueLinePart1Length = valueLinePart1Length;
  }

  /**
   * When valuePosition is OutsideSlice, indicates length of second half of the line
   */
  // @Override
  public getValueLinePart2Length(): number {
    return this.mValueLinePart2Length;
  }

  public setValueLinePart2Length(valueLinePart2Length: number): void {
    this.mValueLinePart2Length = valueLinePart2Length;
  }

  /**
   * When valuePosition is OutsideSlice, this allows variable line length
   */
  // @Override
  public isValueLineVariableLength(): boolean {
    return this.mValueLineVariableLength;
  }

  public setValueLineVariableLength(valueLineVariableLength: boolean): void {
    this.mValueLineVariableLength = valueLineVariableLength;
  }

  /** Gets the color for the highlighted sector */
  // @Override
  // @Nullable
  public getHighlightColor(): number | null {
    return this.mHighlightColor;
  }

  /** Sets the color for the highlighted sector (null for using entry color) */
  public setHighlightColor( /*@Nullable*/
    color: number): void {
    this.mHighlightColor = color;
  }
}

export enum ValuePosition {
  INSIDE_SLICE,
  OUTSIDE_SLICE
}
