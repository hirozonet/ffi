#
# This file is part of ruby-ffi.
# For licensing, see LICENSE.SPECS
#

require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

describe "Function with primitive integer arguments" do
  module LibTest
    extend FFI::Library
    ffi_lib TestLibrary::PATH
    attach_function :ret_s8, [ :char ], :char
    attach_function :ret_u8, [ :uchar ], :uchar
    attach_function :ret_s16, [ :short ], :short
    attach_function :ret_u16, [ :ushort ], :ushort
    attach_function :ret_s32, [ :int ], :int
    attach_function :ret_u32, [ :uint ], :uint
    attach_function :ret_s64, [ :long_long ], :long_long
    attach_function :ret_u64, [ :ulong_long ], :ulong_long
    attach_function :ret_long, [ :long ], :long
    attach_function :ret_ulong, [ :ulong ], :ulong
    attach_function :set_s8, [ :char ], :void
    attach_function :get_s8, [ ], :char
    attach_function :set_float, [ :float ], :void
    attach_function :get_float, [ ], :float
    attach_function :set_double, [ :double ], :void
    attach_function :get_double, [ ], :double
  end

  it "int8.size" do
    expect(FFI::TYPE_INT8.size).to eq(1)
  end

  it "uint8.size" do
    expect(FFI::TYPE_UINT8.size).to eq(1)
  end

  it "int16.size" do
    expect(FFI::TYPE_INT16.size).to eq(2)
  end

  it "uint16.size" do
    expect(FFI::TYPE_UINT16.size).to eq(2)
  end

  it "int32.size" do
    expect(FFI::TYPE_INT32.size).to eq(4)
  end

  it "uint32.size" do
    expect(FFI::TYPE_UINT32.size).to eq(4)
  end

  it "int64.size" do
    expect(FFI::TYPE_INT64.size).to eq(8)
  end

  it "uint64.size" do
    expect(FFI::TYPE_UINT64.size).to eq(8)
  end

  it "float.size" do
    expect(FFI::TYPE_FLOAT32.size).to eq(4)
  end

  it "double.size" do
    expect(FFI::TYPE_FLOAT64.size).to eq(8)
  end
  [ 0, 127, -128, -1 ].each do |i|
    it ":char call(:char (#{i}))" do
      expect(LibTest.ret_s8(i)).to eq(i)
    end
  end
  [ 0, 0x7f, 0x80, 0xff ].each do |i|
    it ":uchar call(:uchar (#{i}))" do
      expect(LibTest.ret_u8(i)).to eq(i)
    end
  end
  [ 0, 0x7fff, -0x8000, -1 ].each do |i|
    it ":short call(:short (#{i}))" do
      expect(LibTest.ret_s16(i)).to eq(i)
    end
  end
  [ 0, 0x7fff, 0x8000, 0xffff ].each do |i|
    it ":ushort call(:ushort (#{i}))" do
      expect(LibTest.ret_u16(i)).to eq(i)
    end
  end
  [ 0, 0x7fffffff, -0x80000000, -1 ].each do |i|
    it ":int call(:int (#{i}))" do
      expect(LibTest.ret_s32(i)).to eq(i)
    end
  end
  [ 0, 0x7fffffff, 0x80000000, 0xffffffff ].each do |i|
    it ":uint call(:uint (#{i}))" do
      expect(LibTest.ret_u32(i)).to eq(i)
    end
  end
  [ 0, 0x7fffffffffffffff, -0x8000000000000000, -1 ].each do |i|
    it ":long_long call(:long_long (#{i}))" do
      expect(LibTest.ret_s64(i)).to eq(i)
    end
  end
  [ 0, 0x7fffffffffffffff, 0x8000000000000000, 0xffffffffffffffff ].each do |i|
    it ":ulong_long call(:ulong_long (#{i}))" do
      expect(LibTest.ret_u64(i)).to eq(i)
    end
  end
  if FFI::Platform::LONG_SIZE == 32
    [ 0, 0x7fffffff, -0x80000000, -1 ].each do |i|
      it ":long call(:long (#{i}))" do
        expect(LibTest.ret_long(i)).to eq(i)
      end
    end
    [ 0, 0x7fffffff, 0x80000000, 0xffffffff ].each do |i|
      it ":ulong call(:ulong (#{i}))" do
        expect(LibTest.ret_ulong(i)).to eq(i)
      end
    end
  else
    [ 0, 0x7fffffffffffffff, -0x8000000000000000, -1 ].each do |i|
      it ":long call(:long (#{i}))" do
        expect(LibTest.ret_long(i)).to eq(i)
      end
    end
    [ 0, 0x7fffffffffffffff, 0x8000000000000000, 0xffffffffffffffff ].each do |i|
      it ":ulong call(:ulong (#{i}))" do
        expect(LibTest.ret_ulong(i)).to eq(i)
      end
    end
    [ 0.0, 0.1, 1.1, 1.23 ].each do |f|
      it ":float call(:double (#{f}))" do
        LibTest.set_float(f)
        expect((LibTest.get_float - f).abs).to be < 0.001
      end
    end
    [ 0.0, 0.1, 1.1, 1.23 ].each do |f|
      it ":double call(:double (#{f}))" do
        LibTest.set_double(f)
        expect((LibTest.get_double - f).abs).to be < 0.001
      end
    end
  end
end
# range checks are not yet supported on TruffleRuby
describe "Integer parameter range checking" do
  [ 128, -129 ].each do |i|
    it ":char call(:char (#{i}))" do
      expect { expect(LibTest.ret_s8(i)).to eq(i) }.to raise_error(Exception) { |error| expect([RSpec::Expectations::ExpectationNotMetError, RangeError]).to be_include(error.class) }
    end
  end
  [ -1, 256 ].each do |i|
    it ":uchar call(:uchar (#{i}))" do
      expect { expect(LibTest.ret_u8(i)).to eq(i) }.to raise_error(Exception) { |error| expect([RSpec::Expectations::ExpectationNotMetError, RangeError]).to be_include(error.class) }
    end
  end
  [ 0x8000, -0x8001 ].each do |i|
    it ":short call(:short (#{i}))" do
      expect { expect(LibTest.ret_s16(i)).to eq(i) }.to raise_error(Exception) { |error| expect([RSpec::Expectations::ExpectationNotMetError, RangeError]).to be_include(error.class) }
    end
  end
  [ -1, 0x10000 ].each do |i|
    it ":ushort call(:ushort (#{i}))" do
      expect { expect(LibTest.ret_u16(i)).to eq(i) }.to raise_error(Exception) { |error| expect([RSpec::Expectations::ExpectationNotMetError, RangeError]).to be_include(error.class) }
    end
  end
  [ 0x80000000, -0x80000001 ].each do |i|
    it ":int call(:int (#{i}))" do
      expect { expect(LibTest.ret_s32(i)).to eq(i) }.to raise_error(Exception) { |error| expect([RSpec::Expectations::ExpectationNotMetError, RangeError]).to be_include(error.class) }
    end
  end
  [ -1, 0x100000000 ].each do |i|
    it ":uint call(:uint (#{i}))" do
      expect { expect(LibTest.ret_u32(i)).to eq(i) }.to raise_error(Exception) { |error| expect([RSpec::Expectations::ExpectationNotMetError, RangeError]).to be_include(error.class) }
    end
  end
end if RUBY_ENGINE != "truffleruby"
describe "Three different size Integer arguments" do
  TYPE_MAP = {
    's8' => :char, 'u8' => :uchar, 's16' => :short, 'u16' => :ushort,
    's32' => :int, 'u32' => :uint, 's64' => :long_long, 'u64' => :ulong_long,
    'sL' => :long, 'uL' => :ulong, 'f32' => :float, 'f64' => :double
  }
  TYPES = TYPE_MAP.keys
  module LibTest
    extend FFI::Library
    ffi_lib TestLibrary::PATH


    [ 's32', 'u32', 's64', 'u64' ].each do |rt|
      TYPES.each do |t1|
        TYPES.each do |t2|
          TYPES.each do |t3|
            begin
              attach_function "pack_#{t1}#{t2}#{t3}_#{rt}",
                [ TYPE_MAP[t1], TYPE_MAP[t2], TYPE_MAP[t3], :buffer_out ], :void
            rescue FFI::NotFoundError
            end
          end
        end
      end
    end
  end

  PACK_VALUES = {
    's8' => [ 0x12  ],
    'u8' => [ 0x34  ],
    's16' => [ 0x5678 ],
    'u16' => [ 0x9abc ],
    's32' => [ 0x7654321f ],
    'u32' => [ 0xfee1babe ],
    'sL' => [ 0x1f2e3d4c ],
    'uL' => [ 0xf7e8d9ca ],
    's64' => [ 0x1eafdeadbeefa1b2 ],
#    'f32' => [ 1.234567 ],
    'f64' => [ 9.87654321 ]
  }

  def verify(p, off, t, v)
    if t == 'f32'
      expect(p.get_float32(off)).to eq(v)
    elsif t == 'f64'
      expect(p.get_float64(off)).to eq(v)
    else
      expect(p.get_int64(off)).to eq(v)
    end
  end

  PACK_VALUES.keys.each do |t1|
    PACK_VALUES.keys.each do |t2|
      PACK_VALUES.keys.each do |t3|
        PACK_VALUES[t1].each do |v1|
          PACK_VALUES[t2].each do |v2|
            PACK_VALUES[t3].each do |v3|
              it "call(#{TYPE_MAP[t1]} (#{v1}), #{TYPE_MAP[t2]} (#{v2}), #{TYPE_MAP[t3]} (#{v3}))" do
                p = FFI::Buffer.new :long_long, 3
                LibTest.send("pack_#{t1}#{t2}#{t3}_s64", v1, v2, v3, p)
                verify(p, 0, t1, v1)
                verify(p, 8, t2, v2)
                verify(p, 16, t3, v3)
              end
            end
          end
        end
      end
    end
  end
end
