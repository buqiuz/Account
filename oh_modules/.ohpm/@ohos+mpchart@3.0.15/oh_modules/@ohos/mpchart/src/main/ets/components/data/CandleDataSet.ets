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
import LineScatterCandleRadarDataSet from './LineScatterCandleRadarDataSet';
import ColorTemplate from '../utils/ColorTemplate';
import { JArrayList } from '../utils/JArrayList';
import CandleEntry from './CandleEntry';
import Utils from '../utils/Utils';
import ICandleDataSet from '../interfaces/datasets/ICandleDataSet';
import { Style } from '../data/Paint';

/**
 * DataSet for the CandleStickChart.
 *
 */
export default class CandleDataSet extends LineScatterCandleRadarDataSet<CandleEntry> implements ICandleDataSet {
  /**
   * the width of the shadow of the candle
   */
  private mShadowWidth: number = 3;
  /**
   * should the candle bars show?
   * when false, only "ticks" will show
   * <p/>
   * - default: true
   */
  private mShowCandleBar: boolean = true;
  /**
   * the space between the candle entries, default 0.1f (10%)
   */
  private mBarSpace: number = 0.1;
  /**
   * use candle color for the shadow
   */
  private mShadowColorSameAsCandle: boolean = false;
  /**
   * paint style when open < close
   * increasing candlesticks are traditionally hollow
   */
  protected mIncreasingPaintStyle: Style = Style.STROKE;
  /**
   * paint style when open > close
   * descreasing candlesticks are traditionally filled
   */
  protected mDecreasingPaintStyle: Style = Style.FILL;
  /**
   * color for open == close
   */
  protected mNeutralColor: number = ColorTemplate.COLOR_SKIP;
  /**
   * color for open < close
   */
  protected mIncreasingColor: number = ColorTemplate.COLOR_SKIP;
  /**
   * color for open > close
   */
  protected mDecreasingColor: number = ColorTemplate.COLOR_SKIP;
  /**
   * shadow line color, set -1 for backward compatibility and uses default
   * color
   */
  protected mShadowColor: number = ColorTemplate.COLOR_SKIP;

  constructor(yVals: JArrayList<CandleEntry>, label: string) {
    super(yVals, label);
  }

  public copy(): DataSet<CandleEntry> {
    let entries = new JArrayList<CandleEntry>();
    if (this.mEntries != null) {
      for (let i = 0; i < this.mEntries.size(); i++) {
        entries.add(this.mEntries.get(i).copy());
      }
    }
    let copied = new CandleDataSet(entries, this.getLabel());
    this.copyTo(copied);
    return copied;
  }

  protected copyTo(candleDataSet: CandleDataSet): void {
    super.copyTo(candleDataSet);
    candleDataSet.mShadowWidth = this.mShadowWidth;
    candleDataSet.mShowCandleBar = this.mShowCandleBar;
    candleDataSet.mBarSpace = this.mBarSpace;
    candleDataSet.mShadowColorSameAsCandle = this.mShadowColorSameAsCandle;
    candleDataSet.mHighLightColor = this.mHighLightColor;
    candleDataSet.mIncreasingPaintStyle = this.mIncreasingPaintStyle;
    candleDataSet.mDecreasingPaintStyle = this.mDecreasingPaintStyle;
    candleDataSet.mNeutralColor = this.mNeutralColor;
    candleDataSet.mIncreasingColor = this.mIncreasingColor;
    candleDataSet.mDecreasingColor = this.mDecreasingColor;
    candleDataSet.mShadowColor = this.mShadowColor;
  }

  public myCalcMinMax(e: CandleEntry): void {

    if (e.getLow() < this.mYMin)
      this.mYMin = e.getLow();

    if (e.getHigh() > this.mYMax)
      this.mYMax = e.getHigh();

    this.calcMinMaxX(e);
  }

  protected myCalcMinMaxY(e: CandleEntry): void {

    if (e.getHigh() < this.mYMin)
      this.mYMin = e.getHigh();

    if (e.getHigh() > this.mYMax)
      this.mYMax = e.getHigh();

    if (e.getLow() < this.mYMin)
      this.mYMin = e.getLow();

    if (e.getLow() > this.mYMax)
      this.mYMax = e.getLow();
  }

  /**
   * Sets the space that is left out on the left and right side of each
   * candle, default 0.1f (10%), max 0.45f, min 0f
   *
   * @param space
   */
  public setBarSpace(space: number): void {

    if (space < 0)
      space = 0;
    if (space > 0.45)
      space = 0.45;

    this.mBarSpace = space;
  }

  public getBarSpace(): number {
    return this.mBarSpace;
  }

  /**
   * Sets the width of the candle-shadow-line in pixels. Default 3f.
   *
   * @param width
   */
  public setShadowWidth(width: number): void {
    this.mShadowWidth = Utils.handleDataValues(width);
    // this.mShadowWidth = width;
  }

  public getShadowWidth(): number {
    return this.mShadowWidth;
  }

  /**
   * Sets whether the candle bars should show?
   *
   * @param showCandleBar
   */
  public setShowCandleBar(showCandleBar: boolean): void {
    this.mShowCandleBar = showCandleBar;
  }

  public getShowCandleBar(): boolean {
    return this.mShowCandleBar;
  }

  /**
   * It is necessary to implement ColorsList class that will encapsulate
   * colors list functionality, because It's wrong to copy paste setColor,
   * addColor, ... resetColors for each time when we want to add a coloring
   * options for one of objects
   *
   * @author Mesrop
   */

  /** BELOW THIS COLOR HANDLING */

  /**
   * Sets the one and ONLY color that should be used for this DataSet when
   * open == close.
   *
   * @param color
   */
  public setNeutralColor(color: number): void {
    this.mNeutralColor = color;
  }

  public getNeutralColor(): number {
    return this.mNeutralColor;
  }

  /**
   * Sets the one and ONLY color that should be used for this DataSet when
   * open <= close.
   *
   * @param color
   */
  public setIncreasingColor(color: number): void {
    this.mIncreasingColor = color;
  }

  public getIncreasingColor(): number {
    return this.mIncreasingColor;
  }

  /**
   * Sets the one and ONLY color that should be used for this DataSet when
   * open > close.
   *
   * @param color
   */
  public setDecreasingColor(color: number): void {
    this.mDecreasingColor = color;
  }

  public getDecreasingColor(): number {
    return this.mDecreasingColor;
  }

  public getIncreasingPaintStyle(): Style {
    return this.mIncreasingPaintStyle;
  }

  /**
   * Sets paint style when open < close
   *
   * @param paintStyle
   */
  public setIncreasingPaintStyle(paintStyle: Style): void {
    this.mIncreasingPaintStyle = paintStyle;
  }

  public getDecreasingPaintStyle(): Style {
    return this.mDecreasingPaintStyle;
  }

  /**
   * Sets paint style when open > close
   *
   * @param decreasingPaintStyle
   */
  public setDecreasingPaintStyle(decreasingPaintStyle: Style): void {
    this.mDecreasingPaintStyle = decreasingPaintStyle;
  }

  public getShadowColor(): number {
    return this.mShadowColor;
  }

  /**
   * Sets shadow color for all entries
   *
   * @param shadowColor
   */
  public setShadowColor(shadowColor: number): void {
    this.mShadowColor = shadowColor;
  }

  public getShadowColorSameAsCandle(): boolean {
    return this.mShadowColorSameAsCandle;
  }

  /**
   * Sets shadow color to be the same color as the candle color
   *
   * @param shadowColorSameAsCandle
   */
  public setShadowColorSameAsCandle(shadowColorSameAsCandle: boolean): void {
    this.mShadowColorSameAsCandle = shadowColorSameAsCandle;
  }
}
