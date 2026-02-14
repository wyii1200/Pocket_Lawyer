const { validateAdminArgs } = require('firebase-admin/data-connect');

const connectorConfig = {
  connector: 'example',
  serviceId: 'pocketlawyer',
  location: 'us-east4'
};
exports.connectorConfig = connectorConfig;

function getPublicLegalArticles(dcOrOptions, options) {
  const { dc: dcInstance, options: inputOpts} = validateAdminArgs(connectorConfig, dcOrOptions, options, undefined);
  dcInstance.useGen(true);
  return dcInstance.executeQuery('GetPublicLegalArticles', undefined, inputOpts);
}
exports.getPublicLegalArticles = getPublicLegalArticles;

