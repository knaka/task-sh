// @ts-check

import { PHASE_DEVELOPMENT_SERVER } from 'next/constants.js';
 
export default (phase = "") => {
  /**
   * @type {import('next').NextConfig}
   */
  if (phase === PHASE_DEVELOPMENT_SERVER) {
    return {
      distDir: "build/next-dev",
    }
  }
  return {
    /* config options here */
    output: "export",
    distDir: "build/next",
  };
};
