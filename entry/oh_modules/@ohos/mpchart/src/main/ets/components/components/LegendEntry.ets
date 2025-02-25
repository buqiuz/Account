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

import { DashPathEffect } from '../data/Paint';
import ColorTemplate from '../utils/ColorTemplate';
import { LegendForm } from './Legend';

export default class LegendEntry {
  // constructor();
  //
  // constructor(label: string, form: LegendForm, formSize: number, formLineWidth: number,
  //             formLineDashEffect: DashPathEffect, formColor: number);

  /**
   *
   * @param label The legend entry text. A `null` label will start a group.
   * @param form The form to draw for this entry.
   * @param formSize Set to NaN to use the legend's default.
   * @param formLineWidth Set to NaN to use the legend's default.
   * @param formLineDashEffect Set to nil to use the legend's default.
   * @param formColor The color for drawing the form.
   */
  constructor(label ?: string | null, form ?: LegendForm | null, formSize ?: number | null, formLineWidth ?: number | null,
              formLineDashEffect ?: DashPathEffect | null, formColor ?: number | null) {
    this.label = label ? label : '';
    this.form = form ? form : LegendForm.DEFAULT;
    this.formSize = formSize == null || formSize == undefined ? Number.NaN : formSize;
    this.formLineWidth = formLineWidth == null || formLineWidth == undefined ? Number.NaN : formLineWidth;
    this.formLineDashEffect = formLineDashEffect == undefined || formLineDashEffect == null ? null : formLineDashEffect;
    this.formColor = formColor == null || formColor == undefined ? 0 : formColor;
  }

  /**
   * The legend entry text.
   * A `null` label will start a group.
   */
  public label: string = '';
  /**
   * The form to draw for this entry.
   *
   * `NONE` will avoid drawing a form, and any related space.
   * `EMPTY` will avoid drawing a form, but keep its space.
   * `DEFAULT` will use the Legend's default.
   */
  public form: LegendForm = LegendForm.DEFAULT;
  /**
   * Form size will be considered except for when .None is used
   *
   * Set as NaN to use the legend's default
   */
  public formSize: number = Number.NaN;
  /**
   * Line width used for shapes that consist of lines.
   *
   * Set as NaN to use the legend's default
   */
  public formLineWidth: number = Number.NaN;
  /**
   * Line dash path effect used for shapes that consist of lines.
   *
   * Set to null to use the legend's default
   */
  public formLineDashEffect: DashPathEffect | null = null;
  /**
   * The color for drawing the form
   */
  public formColor: number = ColorTemplate.COLOR_NONE;
  // public colorArr:Number[]=[]
  // public colorItemSpace:number=3
  // public colorLabelSpace:number=4
  // public colorWidth:number=10
  // public colorHeight:number=10
  // public labelColor:number=Color.Black
  // public labelTextSize:number=10
  // public islableNeedNewLine:boolean=false
}