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

import { ScatterData } from '../data/ScatterData';
import { ScatterDataProvider } from '../interfaces/dataprovider/ScatterDataProvider';
import ScatterChartRenderer from '../renderer/ScatterChartRenderer';
import BarLineChartBaseModel from './BarLineChartBaseModel';

/**
 * The ScatterChart. Draws dots, triangles, squares and custom shapes into the
 * Chart-View. CIRCLE and SCQUARE offer the best performance, TRIANGLE has the
 * worst performance.
 *
 */
export default class ScatterChartModel extends BarLineChartBaseModel<ScatterData> implements ScatterDataProvider {
  // ScatterData() {
  //   throw new Error('Method not implemented.');
  // }

  constructor() {
    super();
    this.init();
  }

  public onChartSizeChanged(newWidth: number, newHeight: number, oldWidth: number, oldHeight: number) {
    super.onSizeChanged(newWidth, newHeight, oldWidth, oldHeight);
  }

  // constructor( context:Context,attrs?:AttributeSet,defStyle?:number) {
  //     super(context,attrs,defStyle);
  // }
  public context2d: CanvasRenderingContext2D | null = null;

  public invalidate() {
    if (this.context2d) {
      this.onDraw(this.context2d);
    }
  }

  public invalidateHighlight() {
    this.invalidate();
  }

  public setContext2D(context2d: CanvasRenderingContext2D) {
    this.context2d = context2d
  }

  public onDraw(c: CanvasRenderingContext2D): void {
    super.onDraw(c);
  }

  // @Override
  protected init(): void {
    super.init();
    if (this.mAnimator) {
      this.mRenderer = new ScatterChartRenderer(this, this.mAnimator, this.mViewPortHandler);
    }


    this.getXAxis()?.setSpaceMin(0.5);
    this.getXAxis()?.setSpaceMax(0.5);
  }

  // @Override
  public getScatterData(): ScatterData | null {
    if (this.mData) {
      return this.mData;
    } else {
      return null;
    }
  }
}

/**
 * Predefined ScatterShapes that allow the specification of a shape a ScatterDataSet should be drawn with.
 * If a ScatterShape is specified for a ScatterDataSet, the required renderer is set.
 */
export enum ChartShape {
  SQUARE, CIRCLE, TRIANGLE, CROSS, X, CHEVRON_UP, CHEVRON_DOWN
}


export class ScatterShape {
  // public static SQUARE: string = "SQUARE"
  // public static CIRCLE: string = "CIRCLE"
  // public static TRIANGLE: string = "TRIANGLE"
  // public static CROSS: string = "CROSS"
  // public static X: string = "X"
  // public static CHEVRON_UP: string = "CHEVRON_UP"
  // public static CHEVRON_DOWN: string = "CHEVRON_DOWN";
  //
  private shapeIdentifier: string;

  constructor(shapeIdentifier: string) {
    this.shapeIdentifier = shapeIdentifier;
  }

  // @Override
  public toString(): String {
    return this.shapeIdentifier;
  }

  public static getAllDefaultShapes(): ChartShape[] {
    return [ChartShape.SQUARE, ChartShape.CIRCLE, ChartShape.TRIANGLE, ChartShape.CROSS, ChartShape.X, ChartShape.CHEVRON_UP, ChartShape.CHEVRON_DOWN];
  }
}