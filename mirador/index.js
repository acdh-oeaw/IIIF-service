import Mirador from 'mirador/dist/es/src/index';
import { miradorImageToolsPlugin } from 'mirador-image-tools';

Mirador.viewer(config, [
  ...miradorImageToolsPlugin,
]);
