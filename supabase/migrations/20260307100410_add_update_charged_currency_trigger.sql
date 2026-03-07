CREATE TRIGGER update_charged_currency_trigger BEFORE UPDATE OF account_id ON public.transactions FOR EACH ROW EXECUTE FUNCTION public.set_transaction_charged_currency();


