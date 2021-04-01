/*
 * generated by Xtext 2.21.0
 */
package com.intuit.dsl.tests

import com.intuit.dsl.expression.ArithmeticSigned
import com.intuit.dsl.expression.BooleanLiteral
import com.intuit.dsl.expression.Minus
import com.intuit.dsl.expression.NullLiteral
import com.intuit.dsl.expression.NumberLiteral
import com.intuit.dsl.expression.Plus
import com.intuit.dsl.expression.StringLiteral
import com.intuit.dsl.expression.TernaryExpression
import org.junit.jupiter.api.Test

class ExpressionParsingTest extends AbstractExpressionTestCase {

	@Test
	def void testAddition() {
		val plus = expression("3 + 4 + 5") as Plus
		val leftOperand = plus.left as Plus
		assertEquals(3, (leftOperand.left as NumberLiteral).value.intValue)
		assertEquals(4, (leftOperand.right as NumberLiteral).value.intValue)
		assertEquals(5, (plus.right as NumberLiteral).value.intValue)
	}

	@Test
	def void testAddition_2() {
		val plus = expression("-3 + -4 + -5") as Plus
		val leftOperand = plus.left as Plus
		assertEquals(3, ((leftOperand.left as ArithmeticSigned).expression as NumberLiteral).value.intValue)
		assertEquals(4, ((leftOperand.right as ArithmeticSigned).expression as NumberLiteral).value.intValue)
		assertEquals(5, ((plus.right as ArithmeticSigned).expression as NumberLiteral).value.intValue)
	}

	@Test
	def void testSubtraction() {
		val minus = expression("3 - 4 - 5") as Minus
		val leftOperand = minus.left as Minus
		assertEquals(3, (leftOperand.left as NumberLiteral).value.intValue)
		assertEquals(4, (leftOperand.right as NumberLiteral).value.intValue)
		assertEquals(5, (minus.right as NumberLiteral).value.intValue)
	}

	@Test
	def void testSubtraction_2() {
		val minus = expression("-3 - -4 - -5") as Minus
		val leftOperand = minus.left as Minus
		val signedExp = leftOperand.left as ArithmeticSigned
		assertEquals(3, (signedExp.expression as NumberLiteral).value.intValue)
		assertEquals(4, ((leftOperand.right as ArithmeticSigned).expression as NumberLiteral).value.intValue)
		assertEquals(5, ((minus.right as ArithmeticSigned).expression as NumberLiteral).value.intValue)
	}

	@Test
	def void testIf_0() { // optional else
		val ternary = expression("if true then false") as TernaryExpression;
		assertEquals("false", (ternary.truevalue as BooleanLiteral).value)
		assertNull(ternary.falsevalue)
	}

	@Test
	def void testIf_1() { // if else
		val ternary = expression("if true then 'abc' else 'pqr'") as TernaryExpression;
		assertEquals("abc", (ternary.truevalue as StringLiteral).value)
		assertEquals("pqr", (ternary.falsevalue as StringLiteral).value)
	}

	@Test
	def void testIf_2() { // nested if else
		val str = '''
			if true 
			then 'foo' 
			else 
				if false 
				then 'bar' 
				else 'foo-bar'
		'''
		val ternary = expression(str) as TernaryExpression;
		assertEquals("foo", (ternary.truevalue as StringLiteral).value)

		val nestedIf = ternary.falsevalue as TernaryExpression
		assertEquals("bar", (nestedIf.truevalue as StringLiteral).value)
		assertEquals("foo-bar", (nestedIf.falsevalue as StringLiteral).value)
	}

	@Test
	def void testIf_3() { // dangling else
		val str = '''
			if true 
			then 
				if false 
				then 'bar' 
				else 'foo-bar'
		'''
		val ternary = expression(str) as TernaryExpression;
		assertNull(ternary.falsevalue)
		val nestedIf = ternary.truevalue as TernaryExpression
		assertEquals("bar", (nestedIf.truevalue as StringLiteral).value)
		assertEquals("foo-bar", (nestedIf.falsevalue as StringLiteral).value)
	}

	@Test
	def void testIf_4() { // nested dangling else
		val str = '''
			if true 
			then 'foo'
			else 
				if false
				then 
				   	if true
				   	then 'bar'
				   	else 'foo-bar' 
		'''

		val ternary = expression(str) as TernaryExpression;
		assertEquals("foo", (ternary.truevalue as StringLiteral).value)

		val nestedIf = ternary.falsevalue as TernaryExpression
		val secondNestedIf = nestedIf.truevalue as TernaryExpression

		assertEquals("bar", (secondNestedIf.truevalue as StringLiteral).value)
		assertEquals("foo-bar", (secondNestedIf.falsevalue as StringLiteral).value)
	}

	@Test
	def void testUnaryMinus() {
		val signedExp = expression("- 5") as ArithmeticSigned
		assertEquals(5, (signedExp.expression as NumberLiteral).value.intValue)
	}

//TODO: Fix the grammar for this test to pass in a separate PR 
//	@Test
//	def void testUnaryPlus() {
//		val signedExp = expression("+ 5") as ArithmeticSigned
//		assertEquals(5, (signedExp.expression as NumberLiteral).value.intValue)
//	}
	@Test
	def void testStringLiteral() {
		val literal = expression("'bar'") as StringLiteral
		assertEquals("bar", literal.value)
	}

	@Test
	def void testBooleanLiteral_1() {
		val literal = expression("true") as BooleanLiteral
		assertEquals("true", literal.value)
	}

	@Test
	def void testBooleanLiteral_2() {
		val literal = expression("false") as BooleanLiteral
		assertEquals("false", literal.value)
	}

	@Test
	def void testNullLiteral() {
		val literal = expression("null") as NullLiteral
		assertEquals("null", literal.value)
	}

	@Test
	def void testNumberLiteral() {
		val literal = expression("3") as NumberLiteral
		assertEquals(3, literal.value.intValue)
	}

}
