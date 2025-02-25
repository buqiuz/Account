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

import { DashPathEffect, Style } from '../data/Paint';
import ComponentBase from '../components/ComponentBase';
import { ChartColor } from '../utils/ColorTemplate';

/**
 * The limit line is an additional feature for all Line-, Bar- and
 * ScatterCharts. It allows the displaying of an additional line in the chart
 * that marks a certain maximum / limit on the specified axis (x- or y-axis).
 *
 */
export default class LimitLine extends ComponentBase {
  /** limit / maximum (the y-value or xIndex) */
  private mLimit: number = 0.0;
  /** the width of the limit line */
  private mLineWidth: number = 2.0;
  /** the color of the limit line */
  private mLineColor: number | string = ChartColor.rgb(237, 91, 91);
  /** the style of the label text */
  private mTextStyle: Style = Style.FILL_AND_STROKE;
  /** label string that is drawn next to the limit line */
  private mLabel: string = "";
  /** the path effect of this LimitLine that makes dashed lines possible */
  private mDashPathEffect: DashPathEffect | null = null;
  /** indicates the position of the LimitLine label */
  private mLabelPosition: LimitLabelPosition = LimitLabelPosition.RIGHT_TOP;

  constructor(limit: number);

  constructor(limit: number, label: string);

  constructor(limit: number, label?: string) {
    super()
    this.mLimit = limit;
    this.mLabel = label ? label : '';
  }

  /**
   * Returns the limit that is set for this line.
   *
   * @return
   */
  public getLimit(): number {
    return this.mLimit;
  }

  /**
   * set the line width of the chart (min = 0.2f, max = 12f); default 2f NOTE:
   * thinner line == better performance, thicker line == worse performance
   *
   * @param width
   */
  public setLineWidth(width: number) {
    if (width < 0.2)
      width = 0.2;
    if (width > 12.0)
      width = 12.0;
    this.mLineWidth = width;
  }

  /**
   * returns the width of limit line
   *
   * @return
   */
  public getLineWidth(): number {
    return this.mLineWidth;
  }

  /**
   * Sets the linecolor for this LimitLine. Make sure to use
   * getResources().getColor(...)
   *
   * @param color
   */
  public setLineColor(color: number | string) {
    this.mLineColor = color;
  }

  /**
   * Returns the color that is used for this LimitLine
   *
   * @return
   */
  public getLineColor(): number | string {
    return this.mLineColor;
  }

  /**
   * Enables the line to be drawn in dashed mode, e.g. like this "- - - - - -"
   *
   * @param lineLength the length of the line pieces
   * @param spaceLength the length of space in between the pieces
   * @param phase offset, in degrees (normally, use 0)
   */
  public enableDashedLine(lineLength: number, spaceLength: number, phase: number) {
    this.mDashPathEffect = new DashPathEffect([lineLength, spaceLength], phase);
  }

  /**
   * Disables the line to be drawn in dashed mode.
   */
  public disableDashedLine() {
    this.mDashPathEffect = null;
  }

  /**
   * Returns true if the dashed-line effect is enabled, false if not. Default:
   * disabled
   *
   * @return
   */
  public isDashedLineEnabled(): boolean {
    return this.mDashPathEffect == null ? false : true;
  }

  /**
   * returns the DashPathEffect that is set for this LimitLine
   *
   * @return
   */
  public getDashPathEffect(): DashPathEffect | null {
    return this.mDashPathEffect;
  }

  /**
   * Sets the color of the value-text that is drawn next to the LimitLine.
   * Default: Paint.Style.FILL_AND_STROKE
   *
   * @param style
   */
  public setTextStyle(style: Style) {
    this.mTextStyle = style;
  }

  /**
   * Returns the color of the value-text that is drawn next to the LimitLine.
   *
   * @return
   */
  public getTextStyle(): Style {
    return this.mTextStyle;
  }

  /**
   * Sets the position of the LimitLine value label (either on the right or on
   * the left edge of the chart). Not supported for RadarChart.
   *
   * @param pos
   */
  public setLabelPosition(pos: LimitLabelPosition) {
    this.mLabelPosition = pos;
  }

  /**
   * Returns the position of the LimitLine label (value).
   *
   * @return
   */
  public getLabelPosition(): LimitLabelPosition {
    return this.mLabelPosition;
  }

  /**
   * Sets the label that is drawn next to the limit line. Provide "" if no
   * label is required.
   *
   * @param label
   */
  public setLabel(label: string) {
    this.mLabel = label;
  }

  /**
   * Returns the label that is drawn next to the limit line.
   *
   * @return
   */
  public getLabel(): string {
    return this.mLabel;
  }
}

/** enum that indicates the position of the LimitLine label */
export enum LimitLabelPosition {
  LEFT_TOP, LEFT_BOTTOM, RIGHT_TOP, RIGHT_BOTTOM
}
