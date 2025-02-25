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

import { JArrayList } from './JArrayList';

import { ObjectPool } from './ObjectPool';
import { Poolable } from './Poolable';

/**
 * Class for describing width and height dimensions in some arbitrary
 */
export default class FSize extends Poolable {
  public width: number = 0;
  public height: number = 0;
  public static pool: ObjectPool<FSize> = ObjectPool.create(256, new FSize(0, 0))
    .setReplenishPercentage(0.5) as ObjectPool<FSize>;

  instantiate(): Poolable {
    return new FSize(0, 0);
  }

  public static getInstance(width: number, height: number): FSize {
    let result: FSize = FSize.pool.get();
    result.width = width;
    result.height = height;
    return result;
  }

  public static recycleInstance(instance: FSize) {
    FSize.pool.recycle(instance);
  }

  public static recycleInstances(instances: JArrayList<FSize>) {
    FSize.pool.recycleArray(instances);
  }

  constructor();

  constructor(width: number, height: number);

  public constructor(width?: number, height?: number) {
    super()
    if (width !== undefined && width !== null && height !== undefined && height !== null) {
      this.width = width;
      this.height = height;
    }
  }

  public equals(obj: Object): boolean {
    if (obj == null) {
      return false;
    }
    if (this == obj) {
      return true;
    }
    if (obj instanceof FSize) {
      let other: FSize = obj as FSize;
      return this.width == other.width && this.height == other.height;
    }
    return false;
  }

  public toString(): string {
    return this.width + "x" + this.height;
  }

  /**
   * {@inheritDoc}
   */
  /*
    @Override
    public int hashCode() {
        return Float.floatToIntBits(width) ^ Float.floatToIntBits(height);
    }*/
}
