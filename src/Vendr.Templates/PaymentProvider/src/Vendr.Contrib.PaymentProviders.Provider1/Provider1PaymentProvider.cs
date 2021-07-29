using System;
using System.Threading.Tasks;
using Vendr.Core.Api;
using Vendr.Core.Models;
using Vendr.Core.PaymentProviders;
using Vendr.Extensions;

namespace Vendr.Contrib.PaymentProviders.Provider1
{
    [PaymentProvider("Provider1Lower", "Provider1", "Provider1 payment provider")]
    public class Provider1PaymentProvider : PaymentProviderBase<Provider1Settings>
    {
        public Provider1PaymentProvider(VendrContext vendr)
            : base(vendr)
        { }

        public override bool FinalizeAtContinueUrl => true;

        public override Task<PaymentFormResult> GenerateFormAsync(PaymentProviderContext<Provider1Settings> ctx)
        {
            return Task.FromResult(new PaymentFormResult()
            {
                Form = new PaymentForm(ctx.Urls.ContinueUrl, PaymentFormMethod.Post)
            });
        }

        public override string GetCancelUrl(PaymentProviderContext<Provider1Settings> ctx)
        {
            return string.Empty;
        }

        public override string GetErrorUrl(PaymentProviderContext<Provider1Settings> ctx)
        {
            return string.Empty;
        }

        public override string GetContinueUrl(PaymentProviderContext<Provider1Settings> ctx)
        {
            ctx.Settings.MustNotBeNull("ctx.Settings");
            ctx.Settings.ContinueUrl.MustNotBeNull("ctx.Settings.ContinueUrl");

            return ctx.Settings.ContinueUrl;
        }

        public override Task<CallbackResult> ProcessCallbackAsync(PaymentProviderContext<Provider1Settings> ctx)
        {
            return Task.FromResult(new CallbackResult
            {
                TransactionInfo = new TransactionInfo
                {
                    AmountAuthorized = ctx.Order.TransactionAmount.Value,
                    TransactionFee = 0m,
                    TransactionId = Guid.NewGuid().ToString("N"),
                    PaymentStatus = PaymentStatus.Authorized
                }
            });
        }
    }
}