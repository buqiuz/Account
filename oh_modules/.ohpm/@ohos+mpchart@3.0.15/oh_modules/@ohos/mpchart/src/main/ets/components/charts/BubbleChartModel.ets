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

import BubbleData from '../data/BubbleData';
import BubbleDataProvider from '../interfaces/dataprovider/BubbleDataProvider';
import BubbleChartRenderer from '../renderer/BubbleChartRenderer';
import BarLineChartBaseModel from './BarLineChartBaseModel';

export default class BubbleChartModel extends BarLineChartBaseModel<BubbleData> implements BubbleDataProvider {
  constructor() {
    super();
    this.init();
  }

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

  public onChartSizeChanged(newWidth: number, newHeight: number, oldWidth: number, oldHeight: number) {
    super.onSizeChanged(newWidth, newHeight, oldWidth, oldHeight);
  }

  public onDraw(c: CanvasRenderingContext2D): void {
    super.onDraw(c);
  }

  // @Override
  protected init(): void {
    super.init();

    if (this.mAnimator) {
      this.mRenderer = new BubbleChartRenderer(this, this.mAnimator, this.mViewPortHandler);
    }
  }

  public getBubbleData(): BubbleData | null {
    if (this.mData) {
      return this.mData;
    } else {
      return null;
    }
  }
}
