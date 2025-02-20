/**
 * AUTO-GENERATED - DO NOT EDIT. Source: https://github.com/gpuweb/cts
 **/ import { kMaximumLimitBaseParams, makeLimitTestGroup } from './limit_utils.js';
const limit = 'maxTextureDimension3D';
export const { g, description } = makeLimitTestGroup(limit);

g.test('createTexture,at_over')
  .desc(`Test using at and over ${limit} limit`)
  .params(kMaximumLimitBaseParams)
  .fn(async t => {
    const { limitTest, testValueName } = t.params;
    await t.testDeviceWithRequestedMaximumLimits(
      limitTest,
      testValueName,
      async ({ device, shouldError, testValue }) => {
        for (let dimensionIndex = 0; dimensionIndex < 3; ++dimensionIndex) {
          const size = [2, 2, 2];
          size[dimensionIndex] = testValue;

          await t.testForValidationErrorWithPossibleOutOfMemoryError(() => {
            const texture = device.createTexture({
              size,
              format: 'rgba8unorm',
              dimension: '3d',
              usage: GPUTextureUsage.TEXTURE_BINDING,
            });

            // MAINTENANCE_TODO: Remove this 'if' once the bug in chrome is fixed
            // This 'if' is only here because of a bug in Chrome
            // that generates an error calling destroy on an invalid texture.
            // This doesn't affect the test but the 'if' should be removed
            // once the Chrome bug is fixed.
            if (!shouldError) {
              texture.destroy();
            }
          }, shouldError);
        }
      }
    );
  });
