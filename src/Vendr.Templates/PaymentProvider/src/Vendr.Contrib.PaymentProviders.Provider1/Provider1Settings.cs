using Vendr.Core.PaymentProviders;

namespace Vendr.Contrib.PaymentProviders.Provider1
{
    public class Provider1Settings
    {
        [PaymentProviderSetting(Name = "Continue URL", Description = "The URL to continue to after this provider has done processing. eg: /continue/")]
        public string ContinueUrl { get; set; }
    }
}