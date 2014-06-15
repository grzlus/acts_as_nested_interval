module Mediant
  refine Rational do
    def mediant(a)
      Rational( numerator + a.numerator, denominator + a.denominator )
    end
  end
end
