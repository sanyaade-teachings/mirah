# Copyright (c) 2013 The Mirah project authors. All Rights Reserved.
# All contributing project authors may be found in the NOTICE file.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

package org.mirah.jvm.mirrors

import org.jruby.org.objectweb.asm.Opcodes
import org.jruby.org.objectweb.asm.Type
import org.mirah.jvm.types.MemberKind

class Number < BaseType
  def initialize(type:Type, loader:MirrorLoader)
    super(type, Opcodes.ACC_PUBLIC, nil)
    @loader = loader
  end

  def load_methods:boolean
    sort = getAsmType.getSort
    boolean = @loader.loadMirror(Type.BOOLEAN_TYPE)
    add_operators(@loader.loadMirror(Type.DOUBLE_TYPE), boolean)
    if sort != Type.DOUBLE
      add_operators(@loader.loadMirror(Type.FLOAT_TYPE), boolean)
      if sort != Type.FLOAT
        add_operators(@loader.loadMirror(Type.LONG_TYPE), boolean)
      end
      if sort <= Type.INT
        add_operators(@loader.loadMirror(Type.INT_TYPE), boolean)
      end
    end
    BytecodeMirrorLoader.extendClass(
        self, MirrorObjectExtensions.class, @loader)
    true
  end

  def add_operators(type:MirrorType, boolean:MirrorType):void
    add_comparisons(type, boolean)
    add_math("+", type)
    add_math("-", type)
    add_math("*", type)
    add_math("/", type)
    add_math("%", type)
    sort = type.getAsmType.getSort
    if sort == Type.INT || sort == Type.LONG
      add_math("<<", type)
      add_math(">>", type)
      add_math(">>>", type)
      add_math("|", type)
      add_math("&", type)
      add_math("^", type)
    end
  end

  def add_comparisons(type:MirrorType, boolean:MirrorType):void
    add_comparison("<", type, boolean)
    add_comparison("<=", type, boolean)
    add_comparison("==", type, boolean)
    add_comparison("!=", type, boolean)
    add_comparison(">", type, boolean)
    add_comparison(">=", type, boolean)
  end

  def add_math(name:String, type:MirrorType):void
    add(Member.new(
        Opcodes.ACC_PUBLIC, type, name, [type], type, MemberKind.MATH_OP))
  end

  def add_comparison(name:String, type:MirrorType, boolean:MirrorType):void
    add(Member.new(
        Opcodes.ACC_PUBLIC, type, name, [type], boolean,
        MemberKind.COMPARISON_OP))
  end
end
