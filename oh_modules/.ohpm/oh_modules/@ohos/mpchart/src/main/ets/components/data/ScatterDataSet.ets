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

import { ChartShape } from '../charts/ScatterChartModel';

import IScatterDataSet from '../interfaces/datasets/IScatterDataSet';
import ChevronDownShapeRenderer from '../renderer/scatter/ChevronDownShapeRenderer';
import ChevronUpShapeRenderer from '../renderer/scatter/ChevronUpShapeRenderer';
import CircleShapeRenderer from '../renderer/scatter/CircleShapeRenderer';
import CrossShapeRenderer from '../renderer/scatter/CrossShapeRenderer';
import IShapeRenderer from '../renderer/scatter/IShapeRenderer';
import SquareShapeRenderer from '../renderer/scatter/SquareShapeRenderer';
import TriangleShapeRenderer from '../renderer/scatter/TriangleShapeRenderer';
import XShapeRenderer from '../renderer/scatter/XShapeRenderer';
import ColorTemplate from '../utils/ColorTemplate';
import { JArrayList } from '../utils/JArrayList';
import { DataSet } from './DataSet';
import EntryOhos from './EntryOhos';
import LineScatterCandleRadarDataSet from './LineScatterCandleRadarDataSet';

export default class ScatterDataSet extends LineScatterCandleRadarDataSet<EntryOhos> implements IScatterDataSet {
  /**
   * the size the scattershape will have, in density pixels
   */
  private mShapeSize: number = 15;
  /**
   * Renderer responsible for rendering this DataSet, default: square
   */
  protected mShapeRenderer: IShapeRenderer = new SquareShapeRenderer();
  /**
   * The radius of the hole in the shape (applies to Square, Circle and Triangle)
   * - default: 0.0
   */
  private mScatterShapeHoleRadius: number = 0;
  /**
   * Color for the hole in the shape.
   * Setting to `ColorTemplate.COLOR_NONE` will behave as transparent.
   * - default: ColorTemplate.COLOR_NONE
   */
  private mScatterShapeHoleColor: number = ColorTemplate.COLOR_NONE;

  constructor(yVals: JArrayList<EntryOhos>, label: string) {
    super(yVals, label);
  }

  // @Override
  public copy(): DataSet<EntryOhos> {
    const entries: JArrayList<EntryOhos> = new JArrayList<EntryOhos>();
    if (this.mEntries != null) {
      for (let i = 0; i < this.mEntries.size(); i++) {
        entries.add(this.mEntries.get(i).copy());
      }
    }
    const copied: ScatterDataSet = new ScatterDataSet(entries, this.getLabel());
    this.copyTo(copied);
    return copied;
  }

  protected copyTo(scatterDataSet: ScatterDataSet): void {
    super.copyTo(scatterDataSet);
    scatterDataSet.mShapeSize = this.mShapeSize;
    scatterDataSet.mShapeRenderer = this.mShapeRenderer;
    scatterDataSet.mScatterShapeHoleRadius = this.mScatterShapeHoleRadius;
    scatterDataSet.mScatterShapeHoleColor = this.mScatterShapeHoleColor;
  }

  /**
   * Sets the size in density pixels the drawn scattershape will have. This
   * only applies for non custom shapes.
   *
   * @param size
   */
  public setScatterShapeSize(size: number) {
    this.mShapeSize = size;
  }

  // @Override
  public getScatterShapeSize(): number {
    return this.mShapeSize;
  }

  /**
   * Sets the ScatterShape this DataSet should be drawn with. This will search for an available IShapeRenderer and set this
   * renderer for the DataSet.
   *
   * @param shape
   */
  public setScatterShape(shape: ChartShape): void {
    this.mShapeRenderer = ScatterDataSet.getRendererForShape(shape) !;
  }


  /**
   * Sets a new IShapeRenderer responsible for drawing this DataSet.
   * This can also be used to set a custom IShapeRenderer aside from the default ones.
   *
   * @param shapeRenderer
   */
  public setShapeRenderer(shapeRenderer: IShapeRenderer): void {
    this.mShapeRenderer = shapeRenderer;
  }

  public getShapeRenderer(): IShapeRenderer {
    return this.mShapeRenderer;
  }

  /**
   * Sets the radius of the hole in the shape (applies to Square, Circle and Triangle)
   * Set this to <= 0 to remove holes.
   *
   * @param holeRadius
   */
  public setScatterShapeHoleRadius(holeRadius: number): void {
    this.mScatterShapeHoleRadius = holeRadius;
  }

  public getScatterShapeHoleRadius(): number {
    return this.mScatterShapeHoleRadius;
  }

  /**
   * Sets the color for the hole in the shape.
   *
   * @param holeColor
   */
  public setScatterShapeHoleColor(holeColor: number): void {
    this.mScatterShapeHoleColor = holeColor;
  }

  public getScatterShapeHoleColor(): number {
    return this.mScatterShapeHoleColor;
  }

  public static getRendererForShape(shape: ChartShape): IShapeRenderer | null {

    switch (shape) {
      case ChartShape.SQUARE:
        return new SquareShapeRenderer();
      case ChartShape.CIRCLE:
        return new CircleShapeRenderer();
      case ChartShape.TRIANGLE:
        return new TriangleShapeRenderer();
      case ChartShape.CROSS:
        return new CrossShapeRenderer();
      case ChartShape.X:
        return new XShapeRenderer();
      case ChartShape.CHEVRON_UP:
        return new ChevronUpShapeRenderer();
      case ChartShape.CHEVRON_DOWN:
        return new ChevronDownShapeRenderer();
      default:
        return null
    }

  }
}
