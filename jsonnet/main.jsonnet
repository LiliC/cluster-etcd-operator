local etcdMixin = (import 'github.com/etcd-io/etcd/contrib/mixin/mixin.libsonnet');
local openshiftRules = (import 'custom.libsonnet');
local a = if std.objectHasAll(etcdMixin, 'prometheusAlerts') then etcdMixin.prometheusAlerts.groups else [];
local r = if std.objectHasAll(etcdMixin, 'prometheusRules') then etcdMixin.prometheusRules.groups else [];
local o = if std.objectHasAll(openshiftRules, 'prometheusRules') then openshiftRules.prometheusRules.groups else [];
// Exclude rules that are either OpenShift specific or do not work for OpenShift.
// List should be ordered.
local rules = std.map(function(group) group { rules: std.filter(function(rule) !std.setMember(rule.alert, ['etcdHighNumberOfLeaderChanges', 'etcdInsufficientMembers']), super.rules) }
                      , a + r);

{
  apiVersion: 'monitoring.coreos.com/v1',
  kind: 'PrometheusRule',
  metadata: {
    name: 'etcd-prometheus-rules',
    namespace: 'openshift-etcd-operator',
    annotations:
      {
        'include.release.openshift.io/ibm-cloud-managed': 'true',
        'include.release.openshift.io/self-managed-high-availability': 'true',
        'include.release.openshift.io/single-node-developer': 'true',
      },
  },
  spec: {
    groups: rules + o,
  },
}
