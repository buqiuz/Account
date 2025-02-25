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

import { Poolable } from '../utils/Poolable';
import { ObjectPool } from '../utils/ObjectPool';
import Transformer from '../utils/Transformer';
import ViewPortHandler from '../utils/ViewPortHandler';
import Chart from '../charts/ChartModel';
import ViewPortJob from './ViewPortJob';
import ChartData from '../data/ChartData';
import IDataSet from '../interfaces/datasets/IDataSet';
import EntryOhos from '../data/EntryOhos';

export default class MoveViewJob extends ViewPortJob {
  private static pool: ObjectPool<MoveViewJob> = ObjectPool.create(2, new MoveViewJob(null, 0, 0, null, null))
    .setReplenishPercentage(0.5) as ObjectPool<MoveViewJob>;

  public static getInstance(viewPortHandler: ViewPortHandler, xValue: number, yValue: number, trans: Transformer, v: Chart<ChartData<IDataSet<EntryOhos>>>): MoveViewJob {
    let result: MoveViewJob = MoveViewJob.pool.get();
    result.mViewPortHandler = viewPortHandler;
    result.xValue = xValue;
    result.yValue = yValue;
    result.mTrans = trans;
    result.view = v;
    return result;
  }

  public static recycleInstance(instance: MoveViewJob): void {
    MoveViewJob.pool.recycle(instance);
  }

  constructor(viewPortHandler: ViewPortHandler | null, xValue: number, yValue: number, trans: Transformer | null, v: Chart<ChartData<IDataSet<EntryOhos>>> | null) {
    super(viewPortHandler, xValue, yValue, trans, v);
  }

  public run(): void {

    this.pts[0] = this.xValue;
    this.pts[1] = this.yValue;

    if (this.mTrans) {
      this.mTrans.pointValuesToPixel(this.pts);
    }
    if (this.mViewPortHandler && this.view) {
      this.mViewPortHandler.centerViewPort(this.pts, this.view);
    }
    MoveViewJob.recycleInstance(this);
  }

  public instantiate(): Poolable {
    return new MoveViewJob(this.mViewPortHandler, this.xValue, this.yValue, this.mTrans, this.view);
  }
}
