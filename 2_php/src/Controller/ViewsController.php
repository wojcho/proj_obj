<?php

namespace App\Controller;

use App\Entity\User;
use App\Entity\Product;
use App\Entity\Discount;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\HttpFoundation\Response;

#[Route('/views')]
class ViewsController extends AbstractController
{
    #[Route('/users', name: 'app_views_users', methods: ['GET'])]
    public function users(EntityManagerInterface $em): Response
    {
        $users = $em->getRepository(User::class)->findAll();
        return $this->render('users.html.twig', [
            'users' => $users,
        ]);
    }

    #[Route('/products', name: 'app_views_products', methods: ['GET'])]
    public function products(EntityManagerInterface $em): Response
    {
        $products = $em->getRepository(Product::class)->findAll();
        return $this->render('products.html.twig', [
            'products' => $products,
        ]);
    }

    #[Route('/discounts', name: 'app_views_discounts', methods: ['GET'])]
    public function discounts(EntityManagerInterface $em): Response
    {
        $discounts = $em->getRepository(Discount::class)->findAll();
        return $this->render('discounts.html.twig', [
            'discounts' => $discounts,
        ]);
    }
}
