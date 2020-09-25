export PATH="/home/clev_fr/silont-clang/bin:$PATH"
SECONDS=0
ZIPNAME="MegonoOseng-ginkgo-$(date '+%Y%m%d-%H%M').zip"

if ! [ -d "/home/clev_fr/silont-clang" ]; then
echo "Proton clang not found! Cloning..."
if ! git clone -q https://github.com/kdrag0n/proton-clang ~/silont-clang; then
echo "Cloning failed! Aborting..."
exit 1
fi
fi

mkdir -p out
make O=out ARCH=arm64 vendor/ginkgo-perf_defconfig

if [[ $1 == "-r" || $1 == "--regen" ]]; then
cp out/.config arch/arm64/configs/vendor/ginkgo-perf_defconfig
echo -e "\nRegened defconfig succesfully!"
exit 0
else
echo -e "\nStarting compilation...\n"
make -j16 O=out ARCH=arm64 CC=clang LD=ld.lld AR=llvm-ar AS=llvm-as NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- Image.gz-dtb
fi

if [ -f "out/arch/arm64/boot/Image.gz-dtb" ]; then
git clone -q https://github.com/farkhanclev/AnyKernel3.git
cp out/arch/arm64/boot/Image.gz-dtb AnyKernel3
rm -f *zip
cd AnyKernel3
zip -r9 "../$ZIPNAME" * -x '*.git*' README.md *placeholder
cd ..
rm -rf AnyKernel3
echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
if command -v gdrive &> /dev/null; then
gdrive upload --share $ZIPNAME
else
echo "Zip: $ZIPNAME"
fi
rm -rf out
else
echo -e "\nCompilation failed!"
fi

